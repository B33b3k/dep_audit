
# dep_audit

<div align="center">

[![pub version](https://img.shields.io/pub/v/dep_audit.svg?style=flat-square&logo=dart)](https://pub.dev/packages/dep_audit)
[![pub points](https://img.shields.io/pub/points/dep_audit?style=flat-square&logo=dart)](https://pub.dev/packages/dep_audit/score)
[![popularity](https://img.shields.io/pub/popularity/dep_audit?style=flat-square&logo=dart)](https://pub.dev/packages/dep_audit/score)
[![likes](https://img.shields.io/pub/likes/dep_audit?style=flat-square&logo=dart)](https://pub.dev/packages/dep_audit/score)

[![CI](https://img.shields.io/github/actions/workflow/status/B33b3k/dep_audit/ci.yml?branch=main&style=flat-square&logo=github&label=CI)](https://github.com/B33b3k/dep_audit/actions)
[![codecov](https://img.shields.io/codecov/c/github/B33b3k/dep_audit?style=flat-square&logo=codecov&token=4645bec0-ee79-4770-ae83-4ba44f0e6ba9)](https://codecov.io/gh/B33b3k/dep_audit)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

[![Dart](https://img.shields.io/badge/Dart-3.0+-00599C.svg?style=flat-square&logo=dart)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Compatible-02569B.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20Web-lightgrey.svg?style=flat-square)](https://pub.dev/packages/dep_audit)
[![GitHub Packages](https://img.shields.io/badge/GitHub%20Packages-Available-green.svg?style=flat-square&logo=github)](https://github.com/B33b3k/dep_audit/packages)

</div>

---

A powerful, lightweight dependency and package health auditor for Dart & Flutter projects. `dep_audit` scans your `pubspec.yaml` and source code to create a clear, actionable report on your project's dependencies.

> 🎯 **Perfect pub.dev Score**: Rated 160/160 points with full WASM compatibility

## 📋 Table of Contents

- [✨ Features](#-features)
- [📦 Installation](#-installation)
- [🚀 Usage](#-usage)
- [💡 Examples](#-examples)
- [⚙️ Configuration](#️-configuration)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [📝 Changelog](#-changelog)

## ✨ Features

- 🔍 **Outdated Dependencies**: Compares your locked versions against the latest on pub.dev
- 🧹 **Unused Dependencies**: Scans your code for `import` statements to find dependencies that are declared but never used
- ⚠️ **Abandoned Packages**: Checks package metadata for discontinued flags or long periods of inactivity (`stale`)
- 🔧 **Safe Auto-Fixing**: Automatically run safe fixes with a `--fix` flag to remove unused packages and upgrade outdated ones
- 📊 **Multiple Report Formats**: Output reports in human-readable text or machine-readable JSON for CI/CD pipelines
- 🌐 **Cross-Platform**: Works on Linux, macOS, Windows, and Web (WASM compatible)
- ⚡ **Fast & Lightweight**: Minimal dependencies, maximum performance
- 🎯 **CI/CD Ready**: Perfect for automated workflows and quality gates

## 📦 Installation

### Global Installation (Recommended)

Install once globally to use across all your projects:

```bash
dart pub global activate dep_audit
```

### Project-Specific Installation

Add as a dev dependency for team consistency:

```bash
dart pub add --dev dep_audit
```

### GitHub Packages Installation

You can also install from GitHub Packages:

```bash
# Configure GitHub Packages (one-time setup)
dart pub token add https://pub.pkg.github.com

# Install from GitHub Packages
dart pub global activate --source git https://github.com/B33b3k/dep_audit.git
```

### Alternative Sources

| Source | Command | Use Case |
|--------|---------|----------|
| **pub.dev** | `dart pub global activate dep_audit` | ✅ Recommended for most users |
| **GitHub Packages** | `dart pub token add https://pub.pkg.github.com && dart pub global activate dep_audit --hosted-url=https://pub.pkg.github.com` | 🔒 Enterprise/private registries |
| **Git Repository** | `dart pub global activate --source git https://github.com/B33b3k/dep_audit.git` | 🚀 Latest development version |

## 🚀 Usage

### Quick Start

```bash
# Navigate to your Dart/Flutter project
cd your_project

# Run basic audit
dep_audit

# Run with auto-fix
dep_audit --fix

# Include dev dependencies
dep_audit --include-dev

# Generate JSON report for CI
dep_audit --format json
```

### Command Line Options

| Flag                 | Abbreviation | Description                                                 |
| -------------------- | ------------ | ----------------------------------------------------------- |
| `--fix`              |              | 🔧 Automatically apply safe fixes                           |
| `--path <directory>` | `-p`         | 📂 Specify the project path to audit (default: `.`)         |
| `--include-dev`      |              | 🛠️ Include `dev_dependencies` in the audit                  |
| `--format <format>`  | `-f`         | 📄 Output format: `text` or `json` (default: `text`)        |
| `--help`             | `-h`         | ❓ Show help information                                     |
| `--version`          |              | ℹ️ Show version information                                 |

## 💡 Examples

### Basic Audit
```bash
$ dep_audit
✅ Analyzing dependencies for your_project...

📦 DEPENDENCY AUDIT REPORT
╭─────────────────────────────────────╮
│ Project: your_project               │
│ Dependencies: 12 total, 8 analyzed │ 
╰─────────────────────────────────────╯

🔍 OUTDATED (3 found):
├── http: 0.13.5 → 1.2.1 (available)
├── path: 1.8.3 → 1.9.0 (available)  
└── yaml: 3.1.1 → 3.1.2 (available)

🧹 UNUSED (1 found):
└── crypto: declared but never imported

⚠️ ABANDONED (0 found):
No abandoned packages detected.

💡 Run with --fix to automatically update outdated and remove unused dependencies.
```

### Auto-Fix Mode
```bash
$ dep_audit --fix
✅ Analyzing dependencies...
🔧 Applying fixes...
  ├── Upgraded http: 0.13.5 → 1.2.1
  ├── Upgraded path: 1.8.3 → 1.9.0
  ├── Upgraded yaml: 3.1.1 → 3.1.2
  └── Removed unused: crypto
✅ All fixes applied successfully!
```

### CI/CD Integration
```bash
$ dep_audit --format json | jq '.outdated | length'
3

# GitHub Actions workflow
- name: Audit Dependencies
  run: |
    dart pub global activate dep_audit
    dep_audit --format json > audit_report.json
    # Fail if critical issues found
    if [[ $(jq '.outdated | length' audit_report.json) -gt 5 ]]; then
      echo "Too many outdated dependencies!"
      exit 1
    fi
```

## ⚙️ Configuration

Create a `dep_audit.yaml` file in your project root for custom configuration:

```yaml
# dep_audit.yaml
ignore:
  outdated:
    - package_name  # Ignore specific outdated packages
  unused:
    - test_package  # Keep packages that might be used in tests
  abandoned:
    - legacy_pkg    # Accept known legacy packages

thresholds:
  outdated_days: 90     # Consider package outdated after 90 days
  abandoned_days: 365   # Consider package abandoned after 1 year
  
include_dev: false      # Include dev_dependencies by default
auto_fix: false         # Enable auto-fix by default
format: "text"          # Default output format
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Quick Contributing Steps
1. 🍴 Fork the repository
2. 🌱 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💻 Make your changes
4. ✅ Run tests (`dart test`)
5. 📝 Commit your changes (`git commit -m 'Add amazing feature'`)
6. 📤 Push to the branch (`git push origin feature/amazing-feature`)
7. 🔄 Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## 🙏 Acknowledgments

- Built with ❤️ using [Dart](https://dart.dev)
- Inspired by npm-audit and other dependency management tools
- Thanks to all [contributors](https://github.com/B33b3k/dep_audit/graphs/contributors)

---

<div align="center">

**[⬆ Back to Top](#dep_audit)**

Made with ❤️ by [@B33b3k](https://github.com/B33b3k) | [Report Bug](https://github.com/B33b3k/dep_audit/issues) | [Request Feature](https://github.com/B33b3k/dep_audit/issues)

</div>

