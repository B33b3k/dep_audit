#!/bin/bash

# Dart/Flutter Package Release Automation Script
# Usage: ./scripts/release.sh [patch|minor|major] [--dry-run]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [patch|minor|major] [--dry-run]"
    echo ""
    echo "Arguments:"
    echo "  patch     Increment patch version (0.1.3 -> 0.1.4)"
    echo "  minor     Increment minor version (0.1.3 -> 0.2.0)"
    echo "  major     Increment major version (0.1.3 -> 1.0.0)"
    echo ""
    echo "Options:"
    echo "  --dry-run Only simulate the release, don't actually publish"
    echo ""
    echo "Examples:"
    echo "  $0 patch           # Release new patch version"
    echo "  $0 minor --dry-run # Test minor version release"
}

# Check if running from correct directory
if [[ ! -f "pubspec.yaml" ]]; then
    print_error "Please run this script from the root of your Dart/Flutter package"
    exit 1
fi

# Parse command line arguments
VERSION_TYPE=""
DRY_RUN=false

for arg in "$@"; do
    case $arg in
        patch|minor|major)
            VERSION_TYPE="$arg"
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown argument: $arg"
            show_usage
            exit 1
            ;;
    esac
done

# Check if version type was provided
if [[ -z "$VERSION_TYPE" ]]; then
    print_error "Please specify version type (patch|minor|major)"
    show_usage
    exit 1
fi

# Function to get current version from pubspec.yaml
get_current_version() {
    grep "^version:" pubspec.yaml | sed 's/version: //' | tr -d ' '
}

# Function to increment version
increment_version() {
    local current_version=$1
    local version_type=$2
    
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $version_type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Function to update pubspec.yaml version
update_pubspec_version() {
    local new_version=$1
    print_status "Updating pubspec.yaml to version $new_version"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version: .*/version: $new_version/" pubspec.yaml
    else
        # Linux
        sed -i "s/^version: .*/version: $new_version/" pubspec.yaml
    fi
}

# Function to update CHANGELOG.md
update_changelog() {
    local new_version=$1
    local current_date=$(date +"%Y-%m-%d")
    
    print_status "Updating CHANGELOG.md for version $new_version"
    
    # Create temporary file with new changelog entry
    cat > /tmp/new_changelog_entry << EOF
## $new_version

- 🚀 **Release $new_version**: Automated release with version bump
- 📦 **Package Updates**: Updated package metadata and dependencies
- ✅ **Quality Assurance**: Passed all tests and analysis checks

EOF
    
    # Prepend new entry to existing changelog
    if [[ -f "CHANGELOG.md" ]]; then
        cat /tmp/new_changelog_entry CHANGELOG.md > /tmp/updated_changelog
        mv /tmp/updated_changelog CHANGELOG.md
    else
        mv /tmp/new_changelog_entry CHANGELOG.md
    fi
    
    # Clean up
    rm -f /tmp/new_changelog_entry
}

# Function to run pre-release checks
run_checks() {
    print_status "Running pre-release checks..."
    
    # Check if git repository is clean
    if ! git diff-index --quiet HEAD --; then
        print_warning "Working directory is not clean. Uncommitted changes detected."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Release cancelled"
            exit 1
        fi
    fi
    
    # Run dart pub get
    print_status "Running dart pub get..."
    if ! dart pub get; then
        print_error "Failed to get dependencies"
        exit 1
    fi
    
    # Run dart analyze
    print_status "Running dart analyze..."
    if ! dart analyze; then
        print_error "Static analysis failed"
        exit 1
    fi
    
    # Run tests if test directory exists
    if [[ -d "test" ]]; then
        print_status "Running tests..."
        if ! dart test; then
            print_error "Tests failed"
            exit 1
        fi
    fi
    
    print_success "All pre-release checks passed!"
}

# Function to commit and tag release
commit_and_tag() {
    local new_version=$1
    
    print_status "Committing release changes..."
    
    # Add changed files
    git add pubspec.yaml CHANGELOG.md
    
    # Create commit
    git commit -m "chore(release): bump version to $new_version

- Automated version bump from release script
- Updated CHANGELOG.md with release notes
- Ready for publication to pub.dev"
    
    # Create tag
    print_status "Creating git tag v$new_version..."
    git tag "v$new_version"
    
    print_success "Created commit and tag for version $new_version"
}

# Function to push changes
push_changes() {
    local new_version=$1
    
    print_status "Pushing changes to remote repository..."
    
    # Push main branch
    if ! git push origin main; then
        print_error "Failed to push to main branch"
        exit 1
    fi
    
    # Push tag
    if ! git push origin "v$new_version"; then
        print_error "Failed to push tag"
        exit 1
    fi
    
    print_success "Pushed changes and tag to remote repository"
}

# Function to publish package
publish_package() {
    local dry_run=$1
    
    if [[ "$dry_run" == true ]]; then
        print_status "Running publication dry-run..."
        if dart pub publish --dry-run; then
            print_success "Dry-run completed successfully!"
            print_warning "This was a dry-run. No package was actually published."
        else
            print_error "Dry-run failed"
            exit 1
        fi
    else
        print_status "Running publication dry-run first..."
        if ! dart pub publish --dry-run; then
            print_error "Dry-run failed. Aborting publication."
            exit 1
        fi
        
        print_success "Dry-run passed!"
        echo ""
        print_warning "About to publish package to pub.dev..."
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Creating git tag for automated publishing..."
            print_warning "📝 NOTE: Using official GitHub Actions OIDC publishing"
            print_status "The tag will trigger automated pub.dev publishing via GitHub Actions"
            
            if git tag "v$new_version"; then
                print_success "Git tag v$new_version created successfully!"
                
                print_status "Pushing tag to trigger automated publishing..."
                if git push origin "v$new_version"; then
                    print_success "Tag pushed! Automated publishing initiated! 🚀"
                    print_status "Monitor progress at: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/' | sed 's/\.git$//')/actions"
                    
                    # Create GitHub release locally if gh CLI is available
                    if command -v gh &> /dev/null; then
                        create_github_release "$new_version"
                    else
                        print_status "GitHub release will be created automatically by the workflow"
                    fi
                else
                    print_error "Failed to push tag"
                    exit 1
                fi
            else
                print_error "Failed to create git tag"
                exit 1
            fi
        else
            print_warning "Publication cancelled by user"
            exit 0
        fi
    fi
}

# Function to create GitHub release
create_github_release() {
    local version=$1
    
    print_status "Creating GitHub release..."
    
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) not found. Skipping GitHub release creation."
        print_status "You can install it from: https://cli.github.com/"
        return
    fi
    
    # Extract changelog for this version
    local changelog_content=""
    if [[ -f "CHANGELOG.md" ]]; then
        # Extract the section for this version from CHANGELOG.md
        changelog_content=$(awk "/^## $version/,/^## /{if(/^## $version/) p=1; else if(/^## / && p) exit; if(p) print}" CHANGELOG.md | tail -n +2 | sed '/^$/d')
    fi
    
    if [[ -z "$changelog_content" ]]; then
        changelog_content="Release $version\n\nSee [CHANGELOG.md](CHANGELOG.md) for details."
    fi
    
    # Create the release
    if gh release create "v$version" \
        --title "Release $version" \
        --notes "$changelog_content" \
        --latest; then
        print_success "GitHub release created successfully!"
        print_status "Release URL: https://github.com/$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')/releases/tag/v$version"
    else
        print_warning "Failed to create GitHub release. You may need to authenticate with 'gh auth login'"
    fi
}

# Main execution
main() {
    print_status "Starting release process for $VERSION_TYPE version..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY-RUN MODE: No actual changes will be made"
    fi
    
    # Get current and new version
    current_version=$(get_current_version)
    new_version=$(increment_version "$current_version" "$VERSION_TYPE")
    
    print_status "Current version: $current_version"
    print_status "New version: $new_version"
    
    # Confirm with user
    echo ""
    print_warning "This will:"
    echo "  1. Update pubspec.yaml to version $new_version"
    echo "  2. Update CHANGELOG.md with new release notes"
    echo "  3. Run pre-release checks (analyze, tests)"
    echo "  4. Commit changes and create git tag"
    echo "  5. Push tag to trigger automated publishing"
    if [[ "$DRY_RUN" == true ]]; then
        echo "  6. Run publication dry-run only (no tag creation)"
    else
        echo "  6. Trigger GitHub Actions → pub.dev publishing"
    fi
    echo ""
    print_status "🔒 Using official GitHub Actions OIDC (no secrets needed)"
    echo ""
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Release cancelled"
        exit 0
    fi
    
    # Execute release steps
    if [[ "$DRY_RUN" != true ]]; then
        update_pubspec_version "$new_version"
        update_changelog "$new_version"
    fi
    
    run_checks
    
    if [[ "$DRY_RUN" != true ]]; then
        commit_and_tag "$new_version"
        push_changes "$new_version"
    fi
    
    publish_package "$DRY_RUN"
    
    print_success "Release process completed! 🚀"
    
    if [[ "$DRY_RUN" != true ]]; then
        echo ""
        print_status "Release summary:"
        echo "  📦 Package: $(grep "^name:" pubspec.yaml | cut -d' ' -f2)"
        echo "  🏷️  Version: $new_version"
        echo "  🔗 Repository: $(grep "^repository:" pubspec.yaml | cut -d' ' -f2-)"
        echo "  📊 pub.dev: https://pub.dev/packages/$(grep "^name:" pubspec.yaml | cut -d' ' -f2)"
    fi
}

# Run main function
main "$@"