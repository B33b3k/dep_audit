# GitHub Packages Setup Guide

This guide explains how to publish and consume the `dep_audit` package using GitHub Packages.

## 📦 Publishing to GitHub Packages

The package is automatically published to both pub.dev and GitHub Packages via GitHub Actions:

- **pub.dev**: Official Dart package registry (primary)
- **GitHub Packages**: GitHub's package registry (backup/enterprise)

### Automated Publishing

When you create a release or push a tag:

1. ✅ **pub.dev**: Published via official dart-lang workflow
2. ✅ **GitHub Packages**: Published via custom workflow
3. ✅ **GitHub Releases**: Created automatically with changelog

## 🔧 Consuming from GitHub Packages

### Prerequisites

1. **GitHub Personal Access Token** with `read:packages` scope
2. **Configure Dart pub** to use GitHub Packages

### Setup Steps

#### 1. Create GitHub Token
```bash
# Go to: https://github.com/settings/tokens
# Create token with 'read:packages' scope
```

#### 2. Configure pub credentials
```bash
# Add GitHub Packages registry
dart pub token add https://pub.pkg.github.com
# Enter your GitHub token when prompted
```

#### 3. Install Package
```bash
# Global installation
dart pub global activate dep_audit --hosted-url=https://pub.pkg.github.com

# Project dependency
dart pub add dep_audit --hosted-url=https://pub.pkg.github.com
```

## 🏢 Enterprise Usage

GitHub Packages is perfect for enterprise environments:

### Private Package Registry
```yaml
# pubspec.yaml
dependency_overrides:
  dep_audit:
    hosted:
      name: dep_audit
      url: https://pub.pkg.github.com
    version: ^0.1.6
```

### CI/CD Configuration
```yaml
# .github/workflows/your-workflow.yml
- name: Configure GitHub Packages
  run: |
    echo '${{ secrets.GITHUB_TOKEN }}' | dart pub token add https://pub.pkg.github.com

- name: Install dependencies
  run: dart pub get
```

## 🔍 Verification

### Check Package Availability
```bash
# List available versions
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user/packages/container/dep_audit/versions

# Download package info
dart pub deps --hosted-url=https://pub.pkg.github.com
```

### Validate Installation
```bash
# Check installed version
dart pub global list

# Run the tool
dep_audit --version
```

## 🚀 Benefits of GitHub Packages

| Feature | pub.dev | GitHub Packages |
|---------|---------|-----------------|
| **Public Access** | ✅ Free | ✅ Free |
| **Private Packages** | 💰 Paid | ✅ Free for private repos |
| **Enterprise Control** | ❌ Limited | ✅ Full control |
| **Integration** | ✅ Native Dart | ✅ GitHub ecosystem |
| **Bandwidth** | ✅ Unlimited | 📊 GitHub limits |
| **Availability** | ✅ 99.9% | ✅ GitHub uptime |

## 🔧 Troubleshooting

### Common Issues

#### Token Authentication Error
```bash
# Error: Unauthorized
# Solution: Regenerate token with correct scopes
dart pub token remove https://pub.pkg.github.com
dart pub token add https://pub.pkg.github.com
```

#### Package Not Found
```bash
# Error: Package dep_audit not found
# Solution: Ensure package is published to GitHub Packages
curl -H "Authorization: token $TOKEN" \
  https://api.github.com/orgs/B33b3k/packages/container/dep_audit
```

#### Version Conflicts
```bash
# Clear pub cache and reinstall
dart pub cache repair
dart pub global activate dep_audit --hosted-url=https://pub.pkg.github.com
```

## 📝 Additional Resources

- [GitHub Packages Documentation](https://docs.github.com/en/packages)
- [Dart pub.dev Documentation](https://dart.dev/tools/pub/cmd/pub-global)
- [Package Repository](https://github.com/B33b3k/dep_audit)
- [Package on pub.dev](https://pub.dev/packages/dep_audit)