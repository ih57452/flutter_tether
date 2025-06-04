---
sidebar_position: 2
---

# Auth Manager

The `AuthManager` is a crucial helper class within the Tether ecosystem,
designed to simplify user authentication and the management of an associated
user profile. It wraps the Supabase authentication API and provides automatic
caching of a user's profile data from a specified table in your Supabase
`public` schema to a local SQLite table.

## Overview

`AuthManager` streamlines common authentication workflows by:

- Providing standard methods for **sign-up, sign-in (with password or OTP), and
  sign-out**.
- Listening to **Supabase authentication state changes** (`onAuthStateChange`).
- Automatically **fetching the user's profile** from a designated Supabase table
  upon successful authentication.
- **Storing and updating** the user's profile in a corresponding local SQLite
  table.
- **Clearing local profile data** on sign-out or if the profile fetch fails.
- Exposing `ValueNotifier`s for the current Supabase `User` and the locally
  cached `TProfileModel` (your user profile model), enabling reactive UI
  updates.

The key assumption is that your user profile table in Supabase:

1. Resides in the `public` schema.
2. Has a primary key column (typically named `id`) that matches the `id` of the
   Supabase authenticated user (`auth.users.id`).

## Setup & Configuration

### 1. Configure `tether.yaml`

Enable authentication in your `tether.yaml` configuration file:

```yaml
generation:
  authentication:
    enabled: true
    profile_table: 'profiles' # Name of your Supabase profile table
```

This tells Tether to generate the `AuthManager` class and related providers for
the specified profile table.

### 2. Generated Files

When you run `dart run flutter_tether --config tether.yaml`, Tether will
generate:

- **`lib/database/managers/auth_manager.g.dart`**: The core
  `AuthManager<TProfileModel>` class
- **`lib/database/providers/auth_providers.g.dart`**: Riverpod providers for
  easy integration

### 3. Database Schema Requirements

Your Supabase profile table should:

```sql
-- Example profiles table
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    full_name TEXT,
    email TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to view and update their own profile
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);
```

## Usage with Riverpod

### Basic Setup

The generated providers make it easy to use `AuthManager` throughout your app:

```dart
// Access the AuthManager instance
final authManager = ref.watch(authManagerProvider);

// Watch the current authenticated user
final userAsyncValue = ref.watch(currentUserProvider);

// Watch the current user's profile
final profileAsyncValue = ref.watch(currentProfileProvider);
```

### Authentication Methods

#### Sign Up

```dart
class SignUpWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.watch(authManagerProvider);

    return ElevatedButton(
      onPressed: () async {
        try {
          final response = await authManager.signUp(
            email: 'user@example.com',
            password: 'securepassword123',
            data: {
              'username': 'newuser',
              'full_name': 'New User',
            }, // Optional additional data for the auth.users table
          );
          
          if (response.user != null) {
            // Sign up successful - user will need to confirm email
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Check your email to confirm account')),
            );
          }
        } on AuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up failed: ${e.message}')),
          );
        }
      },
      child: Text('Sign Up'),
    );
  }
}
```

#### Sign In with Password

```dart
class SignInWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.watch(authManagerProvider);

    return ElevatedButton(
      onPressed: () async {
        try {
          await authManager.signInWithPassword(
            email: 'user@example.com',
            password: 'password123',
          );
          // On success, profile will be fetched and cached automatically
          Navigator.pushReplacementNamed(context, '/home');
        } on AuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in failed: ${e.message}')),
          );
        }
      },
      child: Text('Sign In'),
    );
  }
}
```

#### Sign In with OTP (Magic Link)

```dart
class OTPSignInWidget extends ConsumerStatefulWidget {
  @override
  _OTPSignInWidgetState createState() => _OTPSignInWidgetState();
}

class _OTPSignInWidgetState extends ConsumerState<OTPSignInWidget> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    final authManager = ref.watch(authManagerProvider);

    if (!_otpSent) {
      return Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signInWithOtp(
                  email: _emailController.text,
                );
                setState(() => _otpSent = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Check your email for the OTP code')),
                );
              } on AuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.message}')),
                );
              }
            },
            child: Text('Send OTP'),
          ),
        ],
      );
    }

    return Column(
      children: [
        TextField(
          controller: _otpController,
          decoration: InputDecoration(labelText: 'Enter OTP Code'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await authManager.signInWithOtp(
                email: _emailController.text,
                token: _otpController.text,
              );
              Navigator.pushReplacementNamed(context, '/home');
            } on AuthException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('OTP verification failed: ${e.message}')),
              );
            }
          },
          child: Text('Verify OTP'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await authManager.resendOtp(
                email: _emailController.text,
                type: OtpType.email,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('OTP resent')),
              );
            } on AuthException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Resend failed: ${e.message}')),
              );
            }
          },
          child: Text('Resend OTP'),
        ),
      ],
    );
  }
}
```

#### Sign Out

```dart
class SignOutWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.watch(authManagerProvider);

    return ElevatedButton(
      onPressed: () async {
        await authManager.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: Text('Sign Out'),
    );
  }
}
```

### Reactive UI with Authentication State

#### Auth State Wrapper

```dart
class AuthWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);

    return userAsyncValue.when(
      data: (user) {
        if (user != null) {
          return HomeScreen(); // User is authenticated
        } else {
          return LoginScreen(); // User is not authenticated
        }
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

#### Profile Display

```dart
class ProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(currentProfileProvider);
    final userAsyncValue = ref.watch(currentUserProvider);

    return profileAsyncValue.when(
      data: (profile) {
        if (profile != null) {
          return Column(
            children: [
              Text('Welcome, ${profile.fullName ?? profile.username}!'),
              if (profile.avatarUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(profile.avatarUrl!),
                ),
              Text('Email: ${profile.email}'),
            ],
          );
        } else {
          return userAsyncValue.when(
            data: (user) => user != null 
              ? Text('Profile not found') 
              : Text('Not signed in'),
            loading: () => CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          );
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Profile error: $error'),
    );
  }
}
```

## Usage without Riverpod

If you're not using Riverpod, you can still use `AuthManager` directly:

```dart
class AuthService {
  late final AuthManager<ProfileModel> _authManager;

  AuthService() {
    _authManager = AuthManager<ProfileModel>(
      supabaseClient: Supabase.instance.client,
      localDb: yourSqliteConnection, // Your SQLite connection
      supabaseProfileTableName: 'profiles',
      localProfileTableName: 'profiles',
      profileFromJsonFactory: ProfileModel.fromJson,
      tableSchemas: globalSupabaseSchema, // Your generated schema
    );

    // Listen to authentication state changes
    _authManager.currentUserNotifier.addListener(_onUserChanged);
    _authManager.currentProfileNotifier.addListener(_onProfileChanged);
  }

  void _onUserChanged() {
    final user = _authManager.currentUserNotifier.value;
    print('User changed: ${user?.id}');
  }

  void _onProfileChanged() {
    final profile = _authManager.currentProfileNotifier.value;
    print('Profile changed: ${profile?.username}');
  }

  Future<void> signIn(String email, String password) async {
    await _authManager.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _authManager.signOut();
  }

  void dispose() {
    _authManager.dispose();
  }
}
```

## Key Features & Notes

### Automatic Profile Synchronization

- **On Sign In**: Profile is automatically fetched from Supabase and cached
  locally
- **On Token Refresh**: Profile is re-fetched to ensure it's up-to-date
- **On Sign Out**: Local profile data is automatically cleared
- **On Profile Not Found**: Local data is cleared and
  `currentProfileNotifier.value` becomes `null`

### Local Caching Strategy

- Uses a **single-user approach**: Only one profile is stored locally at a time
- **Delete and Insert**: When a new profile is fetched, existing local data is
  deleted first
- **Automatic Cleanup**: Local data is cleared on sign-out or authentication
  errors

### Error Handling

- **Network Errors**: Gracefully handled with logging; local data is cleared on
  fetch failures
- **Schema Mismatches**: Logged with clear error messages
- **Authentication Errors**: Propagated as `AuthException` from Supabase

### Best Practices

1. **Always dispose**: Call `authManager.dispose()` when no longer needed
   (handled automatically with Riverpod providers)
2. **Profile table structure**: Ensure your profile table's `id` matches
   `auth.users.id`
3. **Row Level Security**: Enable RLS on your profile table for security
4. **Error boundaries**: Wrap authentication calls in try-catch blocks
5. **Loading states**: Use the reactive providers to show appropriate loading
   states in your UI
