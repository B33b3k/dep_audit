# Contributing to dep_audit

First off, thank you for considering contributing to `dep_audit`! 🎉 

It's people like you that make `dep_audit` such a great tool. This document provides guidelines and information for contributing.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How Can I Contribute?](#how-can-i-contribute)
- [Style Guidelines](#style-guidelines)
- [Commit Convention](#commit-convention)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

### Our Pledge

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) 3.0 or later
- [Git](https://git-scm.com/downloads)
- A GitHub account

### First Time Setup

1. **Fork the repository**
   ```bash
   # Fork via GitHub UI, then clone your fork
   git clone https://github.com/YOUR_USERNAME/dep_audit.git
   cd dep_audit
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/B33b3k/dep_audit.git
   ```

3. **Install dependencies**
   ```bash
   dart pub get
   ```

4. **Verify everything works**
   ```bash
   dart analyze
   dart test
   ```

## Development Setup

### Project Structure
```
dep_audit/
├── bin/dep_audit.dart          # CLI entry point
├── lib/
│   ├── dep_audit.dart          # Main library
│   └── src/                    # Implementation
├── test/                       # Test files
├── example/                    # Usage examples
├── scripts/                    # Automation scripts
└── docs/                      # Documentation
```

### Development Commands

```bash
# Install dependencies
dart pub get

# Run static analysis
dart analyze

# Run all tests
dart test

# Run specific test
dart test test/specific_test.dart

# Run tests with coverage
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# Format code
dart format .

# Build documentation
dart doc

# Run the tool locally
dart run bin/dep_audit.dart

# Activate for global testing
dart pub global activate --source path .
```

### IDE Setup

#### VS Code
Install these extensions:
- [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) (optional)
- [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters)

#### IntelliJ IDEA / Android Studio
- Install the Dart plugin
- Configure the Dart SDK path

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Good Bug Report Structure:**
```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run `dep_audit` with these flags: `--flag`
2. On this type of project: `Flutter app with X dependencies`
3. See error

**Expected behavior**
What you expected to happen.

**Environment:**
 - OS: [e.g. macOS 12.6]
 - Dart SDK: [e.g. 3.1.0]
 - dep_audit version: [e.g. 0.1.3]

**Additional context**
- `pubspec.yaml` content (if relevant)
- Full error output
- Any other context about the problem
```

### 💡 Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues.

**Good Enhancement Structure:**
```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Additional context**
Any other context, screenshots, or examples.
```

### 🔧 Code Contributions

#### Types of Contributions Needed

- **Core Features**: Dependency analysis improvements
- **CLI Enhancements**: Better user interface and options
- **Performance**: Optimizations for large projects
- **Documentation**: Code docs, examples, tutorials
- **Tests**: Unit tests, integration tests
- **Bug Fixes**: Resolving reported issues

#### Development Workflow

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-number
   ```

2. **Make your changes**
   - Write code following our style guidelines
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**
   ```bash
   # Run all checks
   make check
   
   # Or manually:
   dart analyze
   dart test
   dart format --set-exit-if-changed .
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add amazing new feature"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   # Then create PR via GitHub UI
   ```

## Style Guidelines

### Dart Code Style

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

**Key Points:**
- Use `dart format` to format code
- Follow `lowerCamelCase` for variables, functions, and parameters
- Follow `UpperCamelCase` for classes and types
- Use meaningful names and avoid abbreviations
- Prefer `final` over `var` when possible
- Add dartdoc comments for public APIs

**Example:**
```dart
/// Analyzes dependencies in the given [projectPath].
/// 
/// Returns a [DependencyReport] containing found issues.
/// Throws [ProjectNotFoundException] if the project is not found.
Future<DependencyReport> analyzeDependencies({
  required String projectPath,
  bool includeDev = false,
  ReportFormat format = ReportFormat.text,
}) async {
  // Implementation
}
```

### Documentation Style

- Use dartdoc comments (`///`) for public APIs
- Include examples in documentation when helpful
- Keep README and other docs up to date
- Use clear, concise language

### Test Style

- Name tests clearly: `test('should return outdated dependencies when packages are old')`
- Use the Arrange-Act-Assert pattern
- Test both happy path and error cases
- Mock external dependencies

**Example:**
```dart
group('DependencyAnalyzer', () {
  test('should identify outdated dependencies', () async {
    // Arrange
    final analyzer = DependencyAnalyzer();
    final mockProject = createMockProject();
    
    // Act
    final report = await analyzer.analyze(mockProject);
    
    // Assert
    expect(report.outdated, hasLength(2));
    expect(report.outdated.first.name, equals('http'));
  });
});
```

## Commit Convention

We use [Conventional Commits](https://conventionalcommits.org/) for commit messages:

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `perf`: Performance improvements

### Examples
```bash
feat: add support for Flutter web projects
fix: handle missing pubspec.lock gracefully
docs: update installation instructions
test: add tests for dependency scanner
chore(release): bump version to 0.2.0
```

### Scope (optional)
- `cli`: Command-line interface changes
- `core`: Core analysis logic
- `scanner`: Dependency scanning
- `reporter`: Report generation
- `config`: Configuration handling

## Pull Request Process

### Before Submitting

1. **Update documentation** if you've changed APIs
2. **Add tests** for new functionality
3. **Run all checks** locally
4. **Update CHANGELOG.md** if it's a notable change
5. **Ensure PR is focused** - one feature/fix per PR

### PR Description Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🧪 Test improvement
- [ ] 🔧 Chore (maintenance)

## Testing
- [ ] Tests pass locally
- [ ] Added tests for new functionality
- [ ] Updated documentation

## Screenshots (if applicable)
Include screenshots for UI changes.

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

### Review Process

1. **Automated Checks**: CI must pass
2. **Code Review**: At least one maintainer review
3. **Testing**: Verify changes work as expected
4. **Documentation**: Ensure docs are updated
5. **Merge**: Squash and merge with clean commit message

## Release Process

We use automated releases via GitHub Actions:

### For Maintainers

1. **Create release branch**
   ```bash
   git checkout -b release/v0.2.0
   ```

2. **Use release script**
   ```bash
   # Test the release
   ./scripts/release.sh minor --dry-run
   
   # Actually release
   ./scripts/release.sh minor
   ```

3. **Verify release**
   - Check GitHub release is created
   - Verify pub.dev publication
   - Test installation: `dart pub global activate dep_audit`

### Release Schedule

- **Patch releases**: As needed for bug fixes
- **Minor releases**: Monthly for new features
- **Major releases**: When breaking changes are needed

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **PATCH** (0.1.X): Bug fixes, documentation updates
- **MINOR** (0.X.0): New features, backwards compatible
- **MAJOR** (X.0.0): Breaking changes

## Getting Help

- 📖 **Documentation**: Check the [README](README.md) and code comments
- 💬 **Discussions**: Use [GitHub Discussions](https://github.com/B33b3k/dep_audit/discussions) for questions
- 🐛 **Issues**: Use [GitHub Issues](https://github.com/B33b3k/dep_audit/issues) for bugs and feature requests
- 📧 **Email**: Contact maintainers directly for security issues

## Recognition

Contributors will be:
- Listed in [AUTHORS](AUTHORS.md)
- Mentioned in release notes
- Added to the [contributors graph](https://github.com/B33b3k/dep_audit/graphs/contributors)

## Thank You! 🎉

Your contributions make `dep_audit` better for everyone. Whether you're fixing a typo, adding a feature, or reporting a bug, every contribution matters.

Happy coding! 🚀