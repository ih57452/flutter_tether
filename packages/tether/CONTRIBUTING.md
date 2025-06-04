# Contributing to Flutter Tether

Thank you for your interest in contributing to Flutter Tether! This document
provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Process](#contributing-process)
- [Development Guidelines](#development-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Community](#community)

## 🤝 Code of Conduct

This project and everyone participating in it is governed by our Code of
Conduct. By participating, you are expected to uphold this code.

### Our Pledge

We pledge to make participation in our project a harassment-free experience for
everyone, regardless of age, body size, disability, ethnicity, gender identity
and expression, level of experience, nationality, personal appearance, race,
religion, or sexual identity and orientation.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable
  version)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Git](https://git-scm.com/)
- A [GitHub account](https://github.com/join)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (for testing)
- [Node.js](https://nodejs.org/) (for documentation development)

### Types of Contributions

We welcome several types of contributions:

- 🐛 **Bug fixes**
- ✨ **New features**
- 📝 **Documentation improvements**
- 🧪 **Tests**
- 🎨 **Examples and tutorials**
- 🔧 **Tooling improvements**
- 🌐 **Translations**

## 💻 Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/flutter_tether.git
cd flutter_tether

# Add the upstream repository
git remote add upstream https://github.com/cspecter/flutter_tether.git
```

### 2. Project Structure

```
flutter_tether/
├── packages/
│   ├── tether/              # Code generator package
│   └── tether_libs/         # Runtime library package
├── example/
│   └── frontend/            # Example Flutter app
├── docs/                    # Documentation website
├── scripts/                 # Build and utility scripts
└── README.md
```

### 3. Install Dependencies

```bash
# Install Dart dependencies for all packages
dart pub get

# Install dependencies for the generator
cd packages/tether
dart pub get

# Install dependencies for the libs
cd ../tether_libs
dart pub get

# Install dependencies for the example
cd ../../example/frontend
flutter pub get

# Install documentation dependencies
cd ../../docs
npm install
```

### 4. Environment Setup

Create a `.env` file in the example project:

```bash
cd example/frontend
cp .env.example .env
# Edit .env with your Supabase credentials for testing
```

### 5. Run Tests

```bash
# Run all tests
./scripts/test_all.sh

# Or run tests for specific packages
cd packages/tether && dart test
cd packages/tether_libs && dart test
cd example/frontend && flutter test
```

## 🔄 Contributing Process

### 1. Choose an Issue

- Browse [open issues](https://github.com/cspecter/flutter_tether/issues)
- Look for issues labeled `good first issue` for beginners
- Comment on the issue to let others know you're working on it

### 2. Create a Branch

```bash
# Ensure you're on the main branch and it's up to date
git checkout main
git pull upstream main

# Create a new branch for your work
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number-description
```

### 3. Make Your Changes

Follow our [development guidelines](#development-guidelines) when making
changes.

### 4. Test Your Changes

```bash
# Run tests
dart test                    # For generator
flutter test                 # For example app
npm test                     # For docs (if applicable)

# Test the example app
cd example/frontend
flutter run
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "feat: add new feature description"

# Or for bug fixes:
git commit -m "fix: resolve issue with specific component"
```

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `refactor:` - Code refactoring
- `style:` - Code style changes
- `chore:` - Maintenance tasks

## 📋 Development Guidelines

### Code Style

#### Dart Code

- Follow
  [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format code
- Use `dart analyze` to check for issues
- Maximum line length: 120 characters

```bash
# Format code
dart format .

# Analyze code
dart analyze
```

#### Flutter Code

- Follow
  [Flutter style guide](https://flutter.dev/docs/development/tools/formatting)
- Use meaningful widget names
- Keep widgets small and focused
- Use `const` constructors where possible

### File Organization

```dart
// Import order (with blank lines between groups):
// 1. Dart/Flutter imports
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Third-party package imports
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 3. Local imports
import '../models/user.dart';
import 'auth_service.dart';
```

### Documentation Standards

- All public APIs must have documentation comments
- Use `///` for documentation comments
- Include examples for complex APIs
- Document parameters and return values

````dart
/// Manages user authentication and profile data.
///
/// This service handles sign in, sign up, profile updates, and provides
/// reactive streams for authentication state changes.
///
/// Example:
/// ```dart
/// final authManager = AuthManager(supabase);
/// await authManager.signIn(email: 'user@example.com', password: 'password');
/// ```
class AuthManager {
  /// Signs in a user with email and password.
  ///
  /// Returns the user's profile data on successful authentication.
  /// Throws [AuthException] if authentication fails.
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
````

### Error Handling

- Use custom exception types for domain-specific errors
- Provide meaningful error messages
- Include context in error messages

```dart
class TetherException implements Exception {
  final String message;
  final String? code;
  final dynamic cause;

  const TetherException(this.message, {this.code, this.cause});

  @override
  String toString() => 'TetherException: $message${code != null ? ' ($code)' : ''}';
}
```

### Async/Await Guidelines

- Use `async`/`await` over `Future.then()`
- Handle errors with try-catch blocks
- Use `FutureOr<T>` for flexible return types

```dart
// Good
Future<User> getUser(String id) async {
  try {
    final response = await supabase.from('users').select().eq('id', id).single();
    return User.fromJson(response);
  } catch (e) {
    throw TetherException('Failed to fetch user: $e');
  }
}

// Avoid
Future<User> getUser(String id) {
  return supabase.from('users').select().eq('id', id).single()
    .then((response) => User.fromJson(response))
    .catchError((e) => throw TetherException('Failed to fetch user: $e'));
}
```

## 🧪 Testing

### Test Structure

```
test/
├── unit/               # Unit tests
├── integration/        # Integration tests
├── widget/            # Widget tests
└── test_utils/        # Test utilities and mocks
```

### Writing Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthManager', () {
    late AuthManager authManager;
    late MockSupabaseClient mockSupabase;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      authManager = AuthManager(mockSupabase);
    });

    test('should sign in user successfully', () async {
      // Arrange
      final email = 'test@example.com';
      final password = 'password';
      
      when(mockSupabase.auth.signInWithPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => AuthResponse(
        user: User(id: '123', email: email),
        session: Session(accessToken: 'token'),
      ));

      // Act
      final result = await authManager.signIn(email: email, password: password);

      // Assert
      expect(result.email, equals(email));
      verify(mockSupabase.auth.signInWithPassword(
        email: email,
        password: password,
      )).called(1);
    });
  });
}
```

### Test Coverage

- Aim for 80%+ test coverage
- Unit test all public APIs
- Test error conditions and edge cases
- Include integration tests for critical flows

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📝 Documentation

### Code Documentation

- Document all public APIs
- Include usage examples
- Explain complex algorithms or business logic
- Use `@deprecated` for deprecated APIs

### Website Documentation

The documentation website uses [Docusaurus](https://docusaurus.io/).

```bash
# Start development server
cd docs
npm start

# Build for production
npm run build

# Deploy (maintainers only)
npm run deploy
```

### Writing Documentation

- Use clear, concise language
- Include code examples
- Add images/diagrams where helpful
- Test all code examples

````markdown
## Authentication Manager

The `AuthManager` provides a simplified interface for handling user
authentication.

### Basic Usage

```dart
final authManager = ref.watch(authManagerProvider);

// Sign in
await authManager.signIn(
  email: 'user@example.com', 
  password: 'password',
);

// Get current user
final user = await authManager.getCurrentUser();
```
````

### Error Handling

The auth manager throws `AuthException` for authentication errors:

```dart
try {
  await authManager.signIn(email: email, password: password);
} on AuthException catch (e) {
  print('Authentication failed: ${e.message}');
}
```

````
## 📤 Submitting Changes

### Pull Request Process

1. **Update Documentation**: Ensure any new features are documented
2. **Add Tests**: Include tests for new functionality
3. **Update Changelog**: Add entry to `CHANGELOG.md` if significant
4. **Clean Commit History**: Squash commits if needed
5. **Create Pull Request**: Use the PR template

### Pull Request Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Other (please describe)

## Testing
- [ ] Tests pass locally
- [ ] Added new tests for new functionality
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
````

### Review Process

1. **Automated Checks**: CI/CD runs tests and checks
2. **Code Review**: Maintainers review the code
3. **Feedback**: Address any requested changes
4. **Approval**: Maintainer approves and merges

### After Your PR is Merged

- Delete your feature branch
- Update your local main branch
- Consider contributing more!

```bash
# After merge, clean up
git checkout main
git pull upstream main
git branch -d feature/your-feature-name
```

## 👥 Community

### Getting Help

- 📖 [Documentation](https://cspecter.github.io/flutter_tether/)
- 💬 [Discussions](https://github.com/cspecter/flutter_tether/discussions)
- 🐛 [Issues](https://github.com/cspecter/flutter_tether/issues)

### Communication Channels

- **GitHub Discussions** - General questions and community discussions
- **GitHub Issues** - Bug reports and feature requests
- **Pull Requests** - Code review and technical discussions

### Recognition

Contributors are recognized in:

- `CONTRIBUTORS.md` file
- Release notes for significant contributions
- Project documentation

Thank you for contributing to Flutter Tether! 🎉

---

## 📄 License

By contributing to Flutter Tether, you agree that your contributions will be
licensed under the same [MIT License](LICENSE) that covers the project.
