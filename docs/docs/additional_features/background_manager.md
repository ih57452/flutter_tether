---
sidebar_position: 4
---

# Background Service: Background Job Processing

The Background Service unit provides a robust system for executing tasks in a
separate isolate on mobile devices, ensuring operations can continue even when
the app is not in the foreground. It leverages `flutter_background_service` and
integrates with a local SQLite database for persistent job queuing and
management.

## Overview

The system comprises several key components:

- **`BackgroundService` (`tether_libs`)**: The core class responsible for
  initializing and managing the background isolate, registering job handlers,
  and enqueuing jobs.
- **`BackgroundJobManager` (`tether_libs`)**: A manager class for the UI isolate
  to interact with the `background_service_jobs` SQLite table (e.g., querying
  job status, enqueuing jobs).
- **Job Handlers**: Functions you define that execute specific tasks in the
  background isolate.
- **`background_service_jobs` Table**: An SQLite table that stores job details,
  status, and metadata.
- **Riverpod Providers**: For easy integration and state management in the UI.

Key features include:

- **Persistent Job Queue**: Jobs are stored in SQLite and survive app restarts.
- **Isolate-Based Execution**: Tasks run in a separate Dart isolate, preventing
  UI freezes.
- **Type-Safe Payloads**: Job data is typically handled as
  `Map<String, dynamic>`, often JSON-encoded.
- **Status Tracking**: Jobs progress through states like `PENDING`, `RUNNING`,
  `COMPLETED`, `FAILED`.
- **Retry Logic**: Automatic retries for failed jobs, configurable per job.
- **Priority Support**: Influence the order of job execution.

## Setup & Configuration

### 1. Enable in Configuration (`tether.yaml`)

Ensure background services are enabled in your `tether.yaml` (if applicable to
your Tether version for auto-generation of related components):

```yaml
generation:
  background_services:
    enabled: true # Or similar configuration
```

_Tether typically generates the `background_service_jobs` table migration and a
provider for `BackgroundJobManager`._

### 2. Install Dependencies

Add `flutter_background_service` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_background_service: ^5.0.5 # Use the latest compatible version
  sqlite_async: ^0.6.0 # Ensure this is present for database operations
```

### 3. Generated Files (Typical)

- `lib/database/providers/background_job_manager_provider.g.dart` (if generated
  by Tether): Provides `backgroundJobManagerProvider`.
- Database migration for `background_service_jobs` table.

### 4. Database Schema (`background_service_jobs`)

The system relies on a table like the following (based on `BackgroundJob`
model):

```sql
CREATE TABLE background_service_jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_key TEXT NOT NULL,
    payload TEXT,               -- JSON-encoded job parameters
    status TEXT NOT NULL,       -- 'PENDING', 'RUNNING', 'COMPLETED', 'FAILED'
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    last_attempt_at TEXT,      -- ISO8601 timestamp (e.g., YYYY-MM-DDTHH:MM:SS.SSSZ)
    last_error TEXT,
    priority INTEGER DEFAULT 0, -- Higher numbers = higher priority
    created_at TEXT NOT NULL,   -- ISO8601 timestamp
    updated_at TEXT NOT NULL    -- ISO8601 timestamp
);
```

## Core Initialization (`main.dart`)

### 1. Background Service Initialization Callback

This function runs in the separate background isolate.

```dart
// ... imports ...
import 'package:example/database/database_native.dart'
    if (dart.library.html) 'package:example/database/database_web.dart'
    as platform_db; // Conditional import for platform-specific DB setup

@pragma('vm:entry-point')
Future<void> _myAppBackgroundInitialization(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized(); // Important for platform channels

  print("BackgroundService: MyAppBackgroundInitialization - Starting...");

  try {
    // Initialize database FOR THIS ISOLATE
    final appDb = platform_db.getDatabase();
    await appDb.initialize();
    final SqliteConnection backgroundDbConnection = appDb.db as SqliteConnection;
    
    // Set the database connection for the BackgroundService static methods
    BackgroundService.setBackgroundDbConnection(backgroundDbConnection);
    print("BackgroundService: MyAppBackgroundInitialization - Background DB connection set.");

    // Register your job handlers
    BackgroundService.registerJobHandler('dummyTask', _dummyJobHandler);
    // BackgroundService.registerJobHandler('sendEmail', _sendEmailHandler);
    // BackgroundService.registerJobHandler('processImage', _processImageHandler);
    print("BackgroundService: MyAppBackgroundInitialization - Job handlers registered.");

  } catch (e, s) {
    print("BackgroundService: MyAppBackgroundInitialization - CRITICAL ERROR: $e\n$s");
    service.stopSelf(); // Stop service if critical setup fails
    return;
  }
  print("BackgroundService: MyAppBackgroundInitialization - Complete.");
}
```

### 2. Initialize `BackgroundService` in `main()`

Call `BackgroundService.initialize` from your main isolate's `main` function.

```dart
// filepath: example/frontend/lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize other services (e.g., Supabase)
  // await Supabase.initialize(...);

  // Initialize Background Service
  await BackgroundService.initialize(
    appInitializationCallback: _myAppBackgroundInitialization,
    initialNotificationTitle: "My App Service", // Android notification
    initialNotificationContent: "Performing background tasks...", // Android notification
    // Optional: notificationIconName: 'ic_my_app_notification',
  );
  print("Main Isolate: BackgroundService Configured.");

  // ... (ensure default preferences, etc.) ...

  runApp(const ProviderScope(child: MyApp()));
}
```

## Job Management

### 1. Defining Job Handlers

Job handlers are asynchronous functions that perform the actual work. They
receive the `ServiceInstance`, an optional `payload`, and the background
isolate's `SqliteConnection`.

```dart
@pragma('vm:entry-point')
Future<void> _dummyJobHandler(
  ServiceInstance service,
  Map<String, dynamic>? payload,
  SqliteConnection db, // Background isolate's DB connection
) async {
  print("BackgroundService: DummyJobHandler - Started with payload: $payload");
  final message = payload?['message'] ?? 'No message';

  // Simulate work
  for (int i = 0; i < 5; i++) {
    await Future.delayed(const Duration(seconds: 3));
    print("BackgroundService: DummyJobHandler - Working... ($message, step ${i+1})");
    // Optionally update Android foreground notification
    if (service is AndroidServiceInstance && await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
        title: "Dummy Task Progress",
        content: "Processing: $message (Step ${i+1}/5)",
      );
    }
  }

  print("BackgroundService: DummyJobHandler - Finished.");

  if (service is AndroidServiceInstance && await service.isForegroundService()) {
    service.setForegroundNotificationInfo(
      title: "Dummy Task Completed",
      content: "Finished processing: $message",
    );
    // Revert to default notification after a delay
    Future.delayed(const Duration(seconds: 10), () {
      service.setForegroundNotificationInfo(
        title: "My App Service", // Initial title
        content: "Performing background tasks...", // Initial content
      );
    });
  }
}
```

### 2. Enqueuing Jobs from the UI

Use `BackgroundService.job()` from your UI isolate to add a job to the queue.
You must provide the UI isolate's `SqliteConnection`.

```dart
// filepath: example/frontend/lib/ui/tabs/background_tab.dart (Example Usage)

Future<void> _enqueueDummyTask() async {
  // ... (setState for loading state) ...
  try {
    // Get the UI isolate's database connection via Riverpod
    final appDb = await ref.read(databaseProvider.future);
    final uiDbConnection = appDb.db as SqliteConnection;

    final jobId = await BackgroundService.job(
      db: uiDbConnection, // UI isolate's DB connection
      jobKey: 'dummyTask', // Must match a registered handler
      payload: {'message': 'Hello from UI at ${DateTime.now()}'},
      priority: 1, // Optional priority
      maxAttempts: 3, // Optional max attempts
    );

    if (mounted) {
      if (jobId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dummy task enqueued with ID: $jobId')),
        );
      } else {
        // Handle enqueue failure (e.g., handler not registered if service just restarted)
      }
    }
  } catch (e) {
    // Handle error
  } finally {
    // ... (setState to stop loading state) ...
  }
}
```

### 3. `BackgroundJobManager` (UI Isolate)

The `BackgroundJobManager` allows the UI to query and manage jobs from the
`background_service_jobs` table.

**Provider Setup:** Your `background_job_manager_provider.g.dart` (or manually
created provider) should look like this:

```dart
// filepath: example/frontend/lib/database/providers/background_job_manager_provider.g.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:tether_libs/background_service/background_service_manager.dart';
import '../database.dart'; // Your main database provider

final backgroundJobManagerProvider = Provider<BackgroundJobManager>((ref) {
  final appDatabase = ref.watch(databaseProvider).requireValue;
  final dbConnection = appDatabase.db as SqliteConnection; // UI's DB connection
  return BackgroundJobManager(db: dbConnection);
});
```

**Usage:**

```dart
// Accessing the manager in a widget
final jobManager = ref.watch(backgroundJobManagerProvider);

// Get a job by ID
final job = await jobManager.getJobById(someJobId);

// Get pending jobs
final pendingJobs = await jobManager.getJobsByStatus(BackgroundJobStatus.pending);
```

## UI Integration & Status Monitoring

### Controlling the Service

The `BackgroundServiceTab` in the example demonstrates how to start, stop, and
check the status of the service:

```dart
// Start the service
await BackgroundService.start();

// Stop the service
await BackgroundService.stop();

// Check if running
final bool isRunning = await BackgroundService.isRunning();
```

### Displaying Job Status

Create Riverpod providers to stream job status updates:

```dart
// Provider to watch jobs by status (e.g., pending)
final pendingJobsStreamProvider = StreamProvider<List<BackgroundJob>>((ref) async* {
  final manager = ref.watch(backgroundJobManagerProvider);
  while (true) {
    // Periodically poll for updates or use a more sophisticated notification mechanism
    // if your database supports it (e.g., SQLite update hooks via FFI).
    // For simplicity, this example polls.
    yield await manager.getJobsByStatus(BackgroundJobStatus.pending, orderByCreation: 'DESC');
    await Future.delayed(const Duration(seconds: 5)); // Poll interval
  }
});

// Provider to watch a specific job by ID
final jobStreamProvider = StreamProvider.family<BackgroundJob?, int>((ref, jobId) async* {
  final manager = ref.watch(backgroundJobManagerProvider);
  while (true) {
    yield await manager.getJobById(jobId);
    await Future.delayed(const Duration(seconds: 2));
  }
});
```

**Widget Example:**

```dart
class JobStatusDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingJobsAsync = ref.watch(pendingJobsStreamProvider);

    return pendingJobsAsync.when(
      data: (jobs) => jobs.isEmpty
          ? Center(child: Text('No pending jobs'))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return ListTile(
                  title: Text('${job.jobKey} (ID: ${job.id})'),
                  subtitle: Text('Status: ${job.status.name}, Attempts: ${job.attempts}'),
                  // ... more details
                );
              },
            ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
```

## Using `ProviderContainer` for Non-Widget Scenarios (Main Isolate)

Sometimes you need to interact with Riverpod providers (like `databaseProvider`
to get a `SqliteConnection` or `backgroundJobManagerProvider`) outside the
widget tree in your **main UI isolate**, for example, in a service class, a
utility function, or for testing. `ProviderContainer` is the solution for these
main-isolate scenarios.

**Important:** You are responsible for disposing the `ProviderContainer` when
it's no longer needed to prevent memory leaks.

### Example 1: Enqueuing a Job from a Service Class (Main Isolate)

```dart
// This service class runs in the main UI isolate
class MyBackgroundJobEnqueueService {
  final ProviderContainer _container; // Typically, this container would be passed in or be a long-lived one

  MyBackgroundJobEnqueueService(this._container);

  Future<void> scheduleReportGeneration(String reportType) async {
    try {
      // 1. Obtain the UI isolate's database connection from the main container
      final appDatabase = await _container.read(databaseProvider.future);
      final SqliteConnection uiDbConnection = appDatabase.db as SqliteConnection;

      // 2. Enqueue the job
      final jobId = await BackgroundService.job(
        db: uiDbConnection,
        jobKey: 'generateReport', // Ensure this handler is registered
        payload: {'reportType': reportType, 'requestedBy': 'main_isolate_service'},
      );
      print('Report generation job enqueued from Main Isolate Service with ID: $jobId');
    } catch (e) {
      print('Error in MyBackgroundJobEnqueueService enqueuing job: $e');
    }
  }
  // Dispose method might be needed if the container is scoped to this service
}

// Usage (e.g., during app setup or from another main isolate service):
// final mainGlobalContainer = ProviderContainer(); // A longer-lived container
// final jobEnqueueService = MyBackgroundJobEnqueueService(mainGlobalContainer);
// await jobEnqueueService.scheduleReportGeneration('dailySummary');
// Later, when appropriate: mainGlobalContainer.dispose();
```

### Example 2: Reading Job Status for Utilities (Main Isolate)

```dart
// This utility function runs in the main UI isolate
Future<void> checkJobStatusUtility(int jobId) async {
  final container = ProviderContainer(); // Create a temporary container for this utility
  try {
    final jobManager = container.read(backgroundJobManagerProvider);
    final BackgroundJob? job = await jobManager.getJobById(jobId);

    if (job != null) {
      print('Job $jobId Status (from Main Isolate Utility): ${job.status}, Attempts: ${job.attempts}');
    } else {
      print('Job $jobId not found (from Main Isolate Utility).');
    }
  } catch (e) {
    print('Error checking job status in Main Isolate Utility: $e');
  } finally {
    container.dispose(); // Dispose the temporary container
  }
}

// Usage:
// await checkJobStatusUtility(123);
```

## Using `ProviderContainer` within a Job Handler (Background Isolate)

If a background job handler itself has complex internal logic or needs to manage
its own set of dependencies, you can create and use a `ProviderContainer`
_within that job handler_. This container will be **local to the background
isolate and that specific job's execution**; it is **not** connected to your
main UI isolate's `ProviderContainer`.

This pattern is useful for organizing code within the job handler, especially if
it calls multiple services or performs several distinct steps.

### Example: Job Handler with its Own Local `ProviderContainer`

Let's imagine a job handler that needs to fetch data using a service and then
process it using another service, both of which might benefit from being managed
by Riverpod _within the job's scope_.

```dart
// Define services that might be used by the job handler.
// These would typically be in their own files.
class DataFetcherService {
  final SqliteConnection _db;
  DataFetcherService(this._db);

  Future<List<Map<String, dynamic>>> fetchData(String queryKey) async {
    print("BackgroundJob/DataFetcherService: Fetching data for '$queryKey' using ${_db.hashCode}");
    // Simulate DB query using the background isolate's DB connection
    await Future.delayed(const Duration(milliseconds: 500));
    return [{'id': 1, 'data': 'Sample data for $queryKey'}];
  }
}

class DataProcessorService {
  Future<Map<String, dynamic>> process(List<Map<String, dynamic>> rawData) async {
    print("BackgroundJob/DataProcessorService: Processing ${rawData.length} items.");
    await Future.delayed(const Duration(milliseconds: 300));
    return {'processed_count': rawData.length, 'summary': 'Processed successfully'};
  }
}

// Define providers for these services, intended for the job's local container
final dataFetcherProvider = Provider<DataFetcherService>((ref) {
  // This provider would need access to the SqliteConnection.
  // For this example, we'll assume it's made available to the container
  // or the service is constructed directly with it.
  // This is a simplified example; in reality, you'd pass the 'db' from the handler.
  throw UnimplementedError("dataFetcherProvider needs db. Override or pass directly.");
});

final dataProcessorProvider = Provider<DataProcessorService>((ref) {
  return DataProcessorService();
});


// The job handler itself
@pragma('vm:entry-point')
Future<void> _complexDataProcessingJobHandler(
  ServiceInstance service,
  Map<String, dynamic>? payload,
  SqliteConnection db, // This is the background isolate's DB connection
) async {
  final queryKey = payload?['queryKey'] as String?;
  if (queryKey == null) {
    throw ArgumentError("queryKey is required in payload for complexDataProcessingJobHandler.");
  }

  print("BackgroundJob/ComplexHandler: Started for queryKey '$queryKey'. DB: ${db.hashCode}");

  // Create a ProviderContainer local to this job's execution
  final jobContainer = ProviderContainer(
    overrides: [
      // Override dataFetcherProvider to use the 'db' connection passed to the handler
      dataFetcherProvider.overrideWithValue(DataFetcherService(db)),
    ]
  );

  try {
    // Access services through the local container
    final fetcher = jobContainer.read(dataFetcherProvider);
    final processor = jobContainer.read(dataProcessorProvider);

    final rawData = await fetcher.fetchData(queryKey);
    final processedResult = await processor.process(rawData);

    print("BackgroundJob/ComplexHandler: Successfully processed data for '$queryKey'. Result: $processedResult");

    // Example: Store result or update status using the 'db' connection
    await db.execute(
        "INSERT INTO job_results (job_key, query_key, result, processed_at) VALUES (?, ?, ?, ?)",
        ['complexDataProcessing', queryKey, jsonEncode(processedResult), DateTime.now().toIso8601String()]
    );

  } catch (e, s) {
    print("BackgroundJob/ComplexHandler: Error processing data for '$queryKey': $e\n$s");
    throw e; // Re-throw to allow BackgroundService to handle failure/retry
  } finally {
    jobContainer.dispose(); // Crucial: Dispose the local container
    print("BackgroundJob/ComplexHandler: Finished for queryKey '$queryKey'.");
  }
}

// Remember to register this handler in _myAppBackgroundInitialization:
// BackgroundService.registerJobHandler('complexDataProcessing', _complexDataProcessingJobHandler);

// And to enqueue it from the UI isolate:
// await BackgroundService.job(
//   db: uiDbConnection,
//   jobKey: 'complexDataProcessing',
//   payload: {'queryKey': 'userActivity'},
// );
```

**Key points for using `ProviderContainer` inside a job handler:**

- **Isolation**: The `jobContainer` is entirely separate from your UI's main
  `ProviderContainer`. It cannot access providers or states from the UI isolate.
- **Dependency Injection**: It's useful for managing dependencies _within_ the
  complex logic of a single job handler.
- **Database Connection**: The background isolate's `SqliteConnection` (`db`
  parameter to the handler) should be passed to any services within this local
  container that need database access. This can be done via constructor
  injection or by overriding providers as shown.
- **Lifecycle**: Create the `jobContainer` at the beginning of the handler and
  **always `dispose()` it in a `finally` block** to prevent resource leaks
  within the background isolate.
- **Simplicity**: For simpler job handlers, creating a local `ProviderContainer`
  might be overkill. Direct instantiation of necessary helper classes might be
  more straightforward.

**Note on `ProviderContainer` Lifecycle (General):**

- If you create a `ProviderContainer` for a short-lived operation (like a single
  function call, a test, or within a job handler), dispose it in a `finally`
  block.
- If a service class in the main isolate uses a `ProviderContainer`, the
  container might be passed in or created by the service. Its disposal should
  align with the service's lifecycle.
- Avoid creating many short-lived containers frequently in performance-critical
  paths. For UI, always use `ConsumerWidget`, `ConsumerStatefulWidget`, or `ref`
  from hooks.

## Error Handling & Retries

- **Job Handlers**: If a job handler throws an exception, the
  `BackgroundService` catches it, marks the job as `FAILED` in the database, and
  records the error message in `last_error`.
- **Retries**: The service automatically attempts to retry failed jobs up to
  `max_attempts` times. The `attempts` count is incremented.
- **No Retry**: If an error is considered non-recoverable, the job handler can
  catch it and simply return without re-throwing, or throw a specific exception
  type that your `BackgroundService` modification might handle to prevent
  retries.

## Best Practices

- **Idempotent Jobs**: Design job handlers to be idempotent where possible,
  meaning running them multiple times with the same input produces the same
  result without unintended side effects.
- **Granular Jobs**: Break down complex tasks into smaller, manageable jobs.
- **Payloads**: Keep payloads concise and include all necessary information for
  the job to execute independently.
- **Error Reporting**: Implement robust error logging within job handlers and
  consider reporting critical failures to an external monitoring service.
- **Resource Management**: Ensure job handlers clean up any resources they use
  (e.g., temporary files).
- **Background DB Connection**: Always use the `SqliteConnection` provided to
  the job handler for database operations within the background isolate. The UI
  isolate uses its own connection (typically via `databaseProvider`).
- **Testing**: Thoroughly test job handlers and the overall background
  processing flow.

This documentation provides a comprehensive guide to using the Background
Service unit in your Flutter Tether application, leveraging its persistence,
background execution
