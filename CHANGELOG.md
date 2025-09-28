
## [0.1.6] - 2025-09-28

### Fixed
- GitHub Actions repository access issue by making repository public
- Automated publishing pipeline now fully functional

### Removed
- Unnecessary development documentation and troubleshooting files
- Internal scripts and build artifacts from public repository

## [0.1.5] - 2025-09-28

### Added
- Professional README with comprehensive badges and documentation
- GitHub Actions CI/CD pipeline with multi-platform testing (Linux, macOS, Windows)
- Automated code coverage reporting via Codecov
- Contributing guidelines and issue templates
- Automated pub.dev publishing via GitHub OIDC
- Package optimization with .pubignore (reduced size from 57KB to 12KB)

### Changed
- Enhanced package metadata in pubspec.yaml
- Updated documentation structure and formatting
- Improved example code and usage instructions

### Fixed
- Web platform compatibility issues
- Package validation warnings

## 0.1.4

- 🚀 **Automated Publishing**: Implemented official GitHub Actions OIDC publishing
- 🔐 **Enhanced Security**: No more long-lived secrets, using temporary GitHub tokens
- 📊 **Professional Setup**: Complete CI/CD pipeline with coverage reporting
- 🤝 **Contributing Ready**: Full contributor infrastructure with templates and guides
- 📝 **Documentation**: Comprehensive setup guides and professional README with badges

## 0.1.3

- 🌐 **Web Platform Support**: Added web platform compatibility for WASM support
- 🔗 **Improved URLs**: Updated homepage to pub.dev package page for better discoverability
- 🐛 **Issue Tracking**: Added issue tracker URL for enhanced user support
- 📋 **pub.dev Compliance**: Addressed all pub.dev analysis recommendations
- 📈 **Quality Score**: Improved pub.dev score from 155/160 to expected 160/160 points

## 0.1.2

- 🔧 **Package Maintenance**: Updated package metadata and improved pub.dev compatibility
- 📝 **Documentation**: Enhanced package description and documentation
- ✅ **Quality Improvements**: Addressed pub.dev analysis recommendations

## 0.1.1

- ✨ **Comprehensive API Documentation**: Added complete dartdoc comments to all public APIs
- 📖 **Example Usage**: Added example directory with sample code and README
- 🔧 **Code Quality**: Enhanced with analysis_options.yaml and lint rules
- 🐛 **Bug Fixes**: Fixed string interpolation issues throughout codebase
- 📚 **Better Documentation**: Improved pub.dev score with complete documentation

## 0.1.0

- Initial release of `dep_audit`.
- Core features: outdated, unused, and discontinued dependency checks.
- Console and JSON reporting.
