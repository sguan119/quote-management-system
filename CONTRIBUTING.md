# Contributing to Quote Estimator

Thank you for your interest in contributing to Quote Estimator! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project follows a simple code of conduct:

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain a professional tone

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

- Clear, descriptive title
- Steps to reproduce
- Expected vs actual behavior
- iOS/iPadOS version
- Xcode version
- Screenshots (if applicable)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- Clear use case
- Expected behavior
- Why this would be useful
- Possible implementation approach (optional)

### Code Contributions

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Write or update tests
5. Ensure all tests pass
6. Commit your changes (see [Commit Guidelines](#commit-guidelines))
7. Push to your fork
8. Open a Pull Request

## Development Setup

### Prerequisites

- macOS 13.0+
- Xcode 15.0+
- iOS 16.0+ SDK
- Git

### Setup Steps

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/quote-management-system.git
cd quote-management-system

# Open in Xcode
open QuoteEstimator.xcodeproj

# Build and run tests
xcodebuild test -scheme QuoteEstimator -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch)'
```

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Use clear, descriptive names
- Prefer clarity over brevity
- Follow Swift naming conventions
- Use meaningful variable names

### Architecture Patterns

This project uses **MVVM + Repository** pattern:

- **Views**: SwiftUI views only handle UI
- **ViewModels**: Business logic and state management
- **Repositories**: Data access abstraction
- **Services**: External integrations (network, auth, etc.)

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

### Code Organization

```
- Keep files under 500 lines when possible
- One entity per file
- Group related functionality
- Use meaningful folder structure
```

### Documentation

- Add doc comments for public APIs
- Update docs/ when changing architecture
- Keep README.md current
- Document complex algorithms

## Commit Guidelines

### Commit Message Format

```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
feat: Add export to PDF functionality

Implement PDF generation for customer estimates using PDFKit.
Includes proper formatting and customer branding options.

Closes #42

---

fix: Resolve crash when deleting customer with active sync jobs

Added proper cascade delete handling for SyncJob entities.

Fixes #53

---

docs: Update API integration guide

Add examples for Xero and FreshBooks integration.
```

## Pull Request Process

### Before Submitting

- [ ] Code builds without errors
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] No merge conflicts with main branch
- [ ] Code follows project style
- [ ] Commit messages follow guidelines

### PR Template

When creating a PR, include:

**Description**
- What does this PR do?
- Why is this change needed?

**Changes**
- List of key changes

**Testing**
- How was this tested?
- What test cases were added?

**Screenshots** (if UI changes)

**Checklist**
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes (or documented)

### Review Process

1. Automated checks run (when CI is set up)
2. Code review by maintainer(s)
3. Address feedback
4. Approval and merge

## Testing Guidelines

### Unit Tests

- Write tests for all business logic
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Mock external dependencies

Example:
```swift
func testRoomPriceCalculation_WithDiscount_ReturnsCorrectTotal() {
    // Arrange
    let room = createTestRoom(discount: 10.0)

    // Act
    let price = calculator.calculatePrice(for: room)

    // Assert
    XCTAssertEqual(price, expectedPrice, accuracy: 0.01)
}
```

### UI Tests

- Test critical user flows
- Keep tests stable and maintainable
- Use accessibility identifiers
- Document complex test scenarios

## Questions?

- Open an issue for questions
- Check existing issues first
- Be specific and provide context

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🎉
