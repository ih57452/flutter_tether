# Flutter Tether

**Tether** is an opinionated library that connects Supabase and Flutter
applications with automatic code generation, local SQLite caching, and powerful
utilities for building robust mobile apps.

## 🚀 What is Tether?

Tether bridges the gap between Supabase's powerful backend and Flutter's
frontend by providing:

- **🗄️ Automatic Local Database Management** - SQLite with automatic migrations
  and schema mirroring
- **🔧 Code Generation** - Dart models, query builders, and managers from your
  Supabase schema
- **🔄 Seamless Synchronization** - Optimistic updates, caching, and conflict
  resolution
- **⚡ Real-time Updates** - Built-in Supabase real-time subscription support
- **🔍 Full-Text Search** - Leverage Postgres FTS capabilities directly in
  Flutter
- **🔐 Authentication Management** - Complete auth flow with profile management
- **📱 Background Services** - Persistent job queue for background processing
- **⚙️ User Preferences** - Type-safe settings management
- **📰 Feed Management** - Paginated content feeds with search support

## 📚 Documentation

Complete documentation is available at:
**[https://cspecter.github.io/flutter_tether/](https://cspecter.github.io/flutter_tether/)**

## 🛠️ Technology Stack

- [Supabase](https://supabase.com/) - Backend as a Service
- [SQLite Async](https://pub.dev/packages/sqlite_async) - Local database
- [Riverpod](https://riverpod.dev/) - State management (optional but
  recommended)
- [flutter_background_service](https://pub.dev/packages/flutter_background_service) -
  Background processing (optional)

## 🚀 Quick Start

### 1. Installation

```bash
# Core dependencies
flutter pub add tether_libs supabase_flutter sqlite_async sqlite3_flutter_libs supabase equatable uuid

# Code generator
flutter pub add -d tether

# Optional: For Riverpod features
flutter pub add flutter_riverpod

# Optional: For background services
flutter pub add flutter_background_service
```

### 2. Configuration

Create a `tether.yaml` file in your project root:

```yaml
database:
  host: TETHER_SUPABASE_HOST 
  port: TETHER_PORT_NAME 
  database: TETHER_DB_NAME 
  username: TETHER_DB_USERNAME 
  password: TETHER_DB_PASSWORD 
  ssl: TETHER_SSL 

generation:
  output_directory: lib/database
  exclude_tables:
    - '_realtime.*'
    - 'auth.*'
    - 'storage.*'
  
  models:
    enabled: true 
    filename: models.g.dart
    suffix: Model

  client_managers:
    enabled: true 
    use_riverpod: true

  authentication:
    enabled: true
    profile_table: 'profiles'

  background_services:
    enabled: true

  user_preferences:
    enabled: true
```

Create a `.env` file with your Supabase credentials:

```env
TETHER_SUPABASE_HOST=your_supabase_host
TETHER_PORT_NAME=5432
TETHER_DB_NAME=your_database_name
TETHER_DB_USERNAME=your_database_username
TETHER_DB_PASSWORD=your_database_password
TETHER_SSL=true
```

### 3. Generate Code

```bash
dart run flutter_tether --config tether.yaml
```

### 4. Basic Usage

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/database/database.dart';
import 'package:your_app/database/models.g.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the database
    final db = ref.watch(databaseProvider);
    
    // Use generated models and managers
    return db.when(
      data: (database) => FutureBuilder<List<BookModel>>(
        future: database.bookManager.getAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final book = snapshot.data![index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.description ?? ''),
                );
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## 🎯 Key Features

### Automatic Code Generation

- **Models**: Type-safe Dart classes from your database schema
- **Managers**: CRUD operations with caching and sync
- **Query Builders**: Fluent API for complex queries
- **Providers**: Ready-to-use Riverpod providers

### Local-First Architecture

- SQLite database automatically mirrors your Supabase schema
- Optimistic updates for instant UI feedback
- Automatic conflict resolution and synchronization
- Works offline with automatic sync when reconnected

### Advanced Features

- **Authentication Manager**: Complete auth flow with profile management
- **Background Services**: Persistent job queue for long-running tasks
- **User Preferences**: Type-safe settings with reactive updates
- **Feed Management**: Paginated feeds with search and filtering
- **Full-Text Search**: Leverage Postgres FTS in your Flutter app

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md)
for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

## 🆘 Support

- 📖 [Documentation](https://cspecter.github.io/flutter_tether/)
- 🐛 [Issue Tracker](https://github.com/cspecter/flutter_tether/issues)
- 💬 [Discussions](https://github.com/cspecter/flutter_tether/discussions)

## 🙏 Acknowledgments

- [Supabase](https://supabase.com/) for providing an amazing backend platform
- [SQLite](https://sqlite.org/) for the reliable local database
- [SQLite Async](https://pub.dev/packages/sqlite_async) for asynchronous
  database operations
- [Riverpod](https://riverpod.dev/) for excellent state management

---

**Ready to supercharge your Flutter + Supabase development?** Get started with
the [documentation](https://cspecter.github.io/flutter_tether/) today!
