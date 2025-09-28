# Release Scripts

This directory contains automated release scripts for the `dep_audit` package.

## Scripts Available

### 1. Bash Script (`release.sh`)
```bash
./scripts/release.sh [patch|minor|major] [--dry-run]
```

### 2. Python Script (`release.py`)  
```bash
python scripts/release.py [patch|minor|major] [--dry-run]
```

## Usage Examples

### Patch Release (0.1.3 → 0.1.4)
```bash
# Test the release first
./scripts/release.sh patch --dry-run

# Actually release
./scripts/release.sh patch
```

### Minor Release (0.1.3 → 0.2.0)
```bash
./scripts/release.sh minor
```

### Major Release (0.1.3 → 1.0.0)
```bash
./scripts/release.sh major
```

## What the Script Does

1. **Version Validation**: Checks current version and calculates new version
2. **Pre-flight Checks**: 
   - Verifies git working directory is clean
   - Runs `dart pub get`
   - Runs `dart analyze` 
   - Runs `dart test` (if tests exist)
3. **Version Updates**:
   - Updates `pubspec.yaml` with new version
   - Adds new section to `CHANGELOG.md`
4. **Git Operations**:
   - Commits the changes with conventional commit message
   - Creates git tag (e.g., `v0.1.4`)
   - Pushes changes and tag to remote
5. **Publication**:
   - Runs `dart pub publish --dry-run` first
   - Asks for confirmation before publishing
   - Publishes to pub.dev

## Semantic Versioning Guide

- **Patch** (`x.x.X`): Bug fixes, documentation updates, minor improvements
- **Minor** (`x.X.0`): New features, backwards-compatible changes
- **Major** (`X.0.0`): Breaking changes, major API changes

## Dry Run Mode

Use `--dry-run` to test the release process without making any actual changes:

```bash
./scripts/release.sh patch --dry-run
```

This will:
- Show what changes would be made
- Run all checks
- Simulate the publication process
- **NOT** commit, tag, or publish anything

## Requirements

- Git repository with remote configured
- Dart SDK installed
- Package must have `pubspec.yaml` in current directory
- Proper pub.dev authentication setup (`dart pub token add`)

## Troubleshooting

### Permission Denied
```bash
chmod +x scripts/release.sh scripts/release.py
```

### Python Script
Requires Python 3.6+ (usually pre-installed on macOS/Linux):
```bash
python3 scripts/release.py patch
```

### Git Authentication
Make sure you have push access to the repository and pub.dev token configured:
```bash
dart pub token add https://pub.dartlang.org
```