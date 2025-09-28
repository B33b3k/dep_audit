# Makefile for dep_audit package development and release

.PHONY: help install analyze test build clean release-patch release-minor release-major dry-run-patch dry-run-minor dry-run-major

# Default target
help:
	@echo "🚀 dep_audit Development Commands"
	@echo ""
	@echo "📦 Development:"
	@echo "  install        - Install dependencies"
	@echo "  analyze        - Run static analysis" 
	@echo "  test          - Run tests"
	@echo "  test-coverage  - Run tests with coverage report"
	@echo "  build         - Build the package (install + analyze + test)"
	@echo "  clean         - Clean build artifacts"
	@echo ""
	@echo "🏷️ Release:"
	@echo "  release-patch  - Release new patch version (0.1.3 -> 0.1.4)"
	@echo "  release-minor  - Release new minor version (0.1.3 -> 0.2.0)" 
	@echo "  release-major  - Release new major version (0.1.3 -> 1.0.0)"
	@echo ""
	@echo "🧪 Testing:"
	@echo "  dry-run-patch  - Test patch release without publishing"
	@echo "  dry-run-minor  - Test minor release without publishing"
	@echo "  dry-run-major  - Test major release without publishing"
	@echo ""
	@echo "⚡ Quick workflows:"
	@echo "  dev           - Quick development setup (install + analyze + test)"
	@echo "  check         - Full validation before commit"

# Development targets
install:
	dart pub get

analyze:
	dart analyze

test:
	dart test

test-coverage:
	@echo "Running tests with coverage..."
	dart pub global activate coverage
	dart test --coverage=coverage
	dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
	@echo "Coverage report generated: coverage/lcov.info"

build: install analyze test
	@echo "Build completed successfully!"

clean:
	dart pub cache clean
	rm -rf .dart_tool/
	rm -rf build/

# Release targets
release-patch:
	@./scripts/release.sh patch

release-minor:
	@./scripts/release.sh minor

release-major:
	@./scripts/release.sh major

# Dry-run targets
dry-run-patch:
	@./scripts/release.sh patch --dry-run

dry-run-minor:
	@./scripts/release.sh minor --dry-run

dry-run-major:
	@./scripts/release.sh major --dry-run

# Quick development workflow
dev: install analyze test
	@echo "Development checks passed! Ready for development."

# Pre-commit checks
check: install analyze test
	@echo "All checks passed! Ready to commit."