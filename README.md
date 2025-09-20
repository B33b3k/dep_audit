
# dep_audit

<!-- [![pub version](https://img.shields.io/pub/v/dep_audit.svg)](https://pub.dev/packages/dep_audit)
[![pub points](https://img.shields.io/pub/points/dep_audit)](https://pub.dev/packages/dep_audit/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT) -->

A powerful, lightweight dependency and package health auditor for Dart & Flutter projects. `dep_audit` scans your `pubspec.yaml` and source code to create a clear, actionable report on your project's dependencies.



## Features

- **Outdated Dependencies**: Compares your locked versions against the latest on pub.dev.
- **Unused Dependencies**: Scans your code for `import` statements to find dependencies that are declared but never used.
- **Abandoned Packages**: Checks package metadata for discontinued flags or long periods of inactivity (`stale`).
- **Safe Auto-Fixing**: Automatically run safe fixes with a `--fix` flag to remove unused packages and upgrade outdated ones.
- **Multiple Report Formats**: Output reports in human-readable text or machine-readable JSON for CI/CD pipelines.

## Installation & Usage

How you install and run the tool depends on whether you are developing it locally or using a published version.

### 1. Developing & Testing (Before Publishing)

To test your local source code, activate the tool from its path. This allows you to run `dep_audit` from anywhere on your system as if it were published.

**1. Navigate to the `dep_audit` project root:**

```bash
cd /path/to/your/dep_audit
```

**2. Activate the tool from its local path:**

```bash
dart pub global activate --source path .
```

**3. Run it on any other project:**

```bash
cd /path/to/your/other_project
dep_audit
```

### 2. Published Usage (After Publishing to pub.dev)

Once the package is on pub.dev, users can choose one of two methods:

#### Method A: Global Activation (For Solo Use)

Install it once on your system to use it in any project.

```bash
dart pub global activate dep_audit
```

Then, navigate to any project and run `dep_audit`.

#### Method B: Dev Dependency (For Teams)

Add the tool to a specific project to ensure everyone on the team uses the same version.

```bash
# In your project's directory
dart pub add --dev dep_audit

# Run the tool using `dart run`
dart run dep_audit
```

## Common Options

To use an option, add it after the run command (e.g., `dep_audit --fix`).

| Flag                 | Abbreviation | Description                                                 |
| -------------------- | ------------ | ----------------------------------------------------------- |
| `--fix`              |              | Automatically apply safe fixes.                             |
| `--path <directory>` | `-p`         | Specify the project path to audit. Defaults to `.`          |
| `--include-dev`      |              | Include `dev_dependencies` in the audit.                    |
| `--format <format>`  | `-f`         | Set the output format (`text` or `json`). Defaults to `text`. |

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request on the GitHub repository.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.# dep_audit
