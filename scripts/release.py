#!/usr/bin/env python3
"""
Dart/Flutter Package Release Automation Script
Usage: python scripts/release.py [patch|minor|major] [--dry-run]
"""

import os
import sys
import subprocess
import re
import argparse
from datetime import datetime
from pathlib import Path

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def print_status(message):
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

def print_success(message):
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

def print_warning(message):
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")

def print_error(message):
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

def run_command(command, check=True, capture_output=False):
    """Run a shell command and return the result."""
    try:
        if capture_output:
            result = subprocess.run(command, shell=True, check=check, 
                                 capture_output=True, text=True)
            return result.stdout.strip()
        else:
            subprocess.run(command, shell=True, check=check)
            return True
    except subprocess.CalledProcessError as e:
        if capture_output:
            return None
        raise e

def get_current_version():
    """Extract current version from pubspec.yaml."""
    try:
        with open('pubspec.yaml', 'r') as f:
            content = f.read()
            match = re.search(r'^version:\s*(.+)$', content, re.MULTILINE)
            if match:
                return match.group(1).strip()
    except FileNotFoundError:
        print_error("pubspec.yaml not found. Please run from package root.")
        sys.exit(1)
    
    print_error("Could not find version in pubspec.yaml")
    sys.exit(1)

def increment_version(current_version, version_type):
    """Increment version based on type (patch, minor, major)."""
    parts = current_version.split('.')
    if len(parts) != 3:
        print_error(f"Invalid version format: {current_version}")
        sys.exit(1)
    
    major, minor, patch = map(int, parts)
    
    if version_type == 'major':
        major += 1
        minor = 0
        patch = 0
    elif version_type == 'minor':
        minor += 1
        patch = 0
    elif version_type == 'patch':
        patch += 1
    
    return f"{major}.{minor}.{patch}"

def update_pubspec_version(new_version):
    """Update version in pubspec.yaml."""
    print_status(f"Updating pubspec.yaml to version {new_version}")
    
    with open('pubspec.yaml', 'r') as f:
        content = f.read()
    
    updated_content = re.sub(
        r'^version:\s*.+$',
        f'version: {new_version}',
        content,
        flags=re.MULTILINE
    )
    
    with open('pubspec.yaml', 'w') as f:
        f.write(updated_content)

def update_changelog(new_version):
    """Add new entry to CHANGELOG.md."""
    print_status(f"Updating CHANGELOG.md for version {new_version}")
    
    current_date = datetime.now().strftime("%Y-%m-%d")
    
    new_entry = f"""## {new_version}

- 🚀 **Release {new_version}**: Automated release with version bump
- 📦 **Package Updates**: Updated package metadata and dependencies  
- ✅ **Quality Assurance**: Passed all tests and analysis checks

"""
    
    try:
        with open('CHANGELOG.md', 'r') as f:
            existing_content = f.read()
        
        updated_content = new_entry + existing_content
    except FileNotFoundError:
        updated_content = new_entry
    
    with open('CHANGELOG.md', 'w') as f:
        f.write(updated_content)

def run_checks():
    """Run pre-release checks."""
    print_status("Running pre-release checks...")
    
    # Check git status
    git_status = run_command("git status --porcelain", capture_output=True)
    if git_status:
        print_warning("Working directory is not clean. Uncommitted changes detected.")
        response = input("Do you want to continue? (y/N): ")
        if not response.lower().startswith('y'):
            print_error("Release cancelled")
            sys.exit(1)
    
    # Run dart pub get
    print_status("Running dart pub get...")
    run_command("dart pub get")
    
    # Run dart analyze
    print_status("Running dart analyze...")
    run_command("dart analyze")
    
    # Run tests if test directory exists
    if Path("test").exists():
        print_status("Running tests...")
        run_command("dart test")
    
    print_success("All pre-release checks passed!")

def commit_and_tag(new_version):
    """Commit changes and create git tag."""
    print_status("Committing release changes...")
    
    # Add files
    run_command("git add pubspec.yaml CHANGELOG.md")
    
    # Create commit
    commit_message = f"""chore(release): bump version to {new_version}

- Automated version bump from release script
- Updated CHANGELOG.md with release notes
- Ready for publication to pub.dev"""
    
    run_command(f'git commit -m "{commit_message}"')
    
    # Create tag
    print_status(f"Creating git tag v{new_version}...")
    run_command(f"git tag v{new_version}")
    
    print_success(f"Created commit and tag for version {new_version}")

def push_changes(new_version):
    """Push changes to remote repository."""
    print_status("Pushing changes to remote repository...")
    
    # Push main branch
    run_command("git push origin main")
    
    # Push tag
    run_command(f"git push origin v{new_version}")
    
    print_success("Pushed changes and tag to remote repository")

def publish_package(dry_run):
    """Publish package to pub.dev."""
    if dry_run:
        print_status("Running publication dry-run...")
        run_command("dart pub publish --dry-run")
        print_success("Dry-run completed successfully!")
        print_warning("This was a dry-run. No package was actually published.")
    else:
        print_status("Running publication dry-run first...")
        run_command("dart pub publish --dry-run")
        
        print_success("Dry-run passed!")
        print_warning("About to publish package to pub.dev...")
        
        response = input("Are you sure you want to continue? (y/N): ")
        if response.lower().startswith('y'):
            print_status("Publishing package to pub.dev...")
            run_command("dart pub publish")
            print_success("Package published successfully! 🎉")
        else:
            print_warning("Publication cancelled by user")
            sys.exit(0)

def get_package_info():
    """Get package information from pubspec.yaml."""
    with open('pubspec.yaml', 'r') as f:
        content = f.read()
    
    name_match = re.search(r'^name:\s*(.+)$', content, re.MULTILINE)
    repo_match = re.search(r'^repository:\s*(.+)$', content, re.MULTILINE)
    
    package_name = name_match.group(1).strip() if name_match else "unknown"
    repository = repo_match.group(1).strip() if repo_match else "unknown"
    
    return package_name, repository

def main():
    parser = argparse.ArgumentParser(
        description="Automate Dart/Flutter package releases",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/release.py patch           # Release new patch version
  python scripts/release.py minor --dry-run # Test minor version release
        """
    )
    
    parser.add_argument(
        'version_type',
        choices=['patch', 'minor', 'major'],
        help='Type of version increment'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Only simulate the release, don\'t actually publish'
    )
    
    args = parser.parse_args()
    
    # Check if we're in the right directory
    if not Path('pubspec.yaml').exists():
        print_error("Please run this script from the root of your Dart/Flutter package")
        sys.exit(1)
    
    print_status(f"Starting release process for {args.version_type} version...")
    
    if args.dry_run:
        print_warning("DRY-RUN MODE: No actual changes will be made")
    
    # Get versions
    current_version = get_current_version()
    new_version = increment_version(current_version, args.version_type)
    
    print_status(f"Current version: {current_version}")
    print_status(f"New version: {new_version}")
    
    # Confirmation
    print_warning("This will:")
    print("  1. Update pubspec.yaml to version", new_version)
    print("  2. Update CHANGELOG.md with new release notes")
    print("  3. Run pre-release checks (analyze, tests)")
    print("  4. Commit changes and create git tag")
    print("  5. Push to remote repository")
    if args.dry_run:
        print("  6. Run publication dry-run only")
    else:
        print("  6. Publish to pub.dev")
    
    response = input("\nDo you want to continue? (y/N): ")
    if not response.lower().startswith('y'):
        print_error("Release cancelled")
        sys.exit(0)
    
    # Execute release steps
    try:
        if not args.dry_run:
            update_pubspec_version(new_version)
            update_changelog(new_version)
        
        run_checks()
        
        if not args.dry_run:
            commit_and_tag(new_version)
            push_changes(new_version)
        
        publish_package(args.dry_run)
        
        print_success("Release process completed! 🚀")
        
        if not args.dry_run:
            package_name, repository = get_package_info()
            print_status("Release summary:")
            print(f"  📦 Package: {package_name}")
            print(f"  🏷️  Version: {new_version}")
            print(f"  🔗 Repository: {repository}")
            print(f"  📊 pub.dev: https://pub.dev/packages/{package_name}")
    
    except KeyboardInterrupt:
        print_error("\nRelease cancelled by user")
        sys.exit(1)
    except Exception as e:
        print_error(f"Release failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()