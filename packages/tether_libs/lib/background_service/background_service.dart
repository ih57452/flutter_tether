import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/widgets.dart'; // For WidgetsFlutterBinding
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sqlite_async/sqlite_async.dart'; // You'll need a way to access this
import 'package:tether_libs/background_service/background_job_model.dart';
import 'package:tether_libs/background_service/background_service_manager.dart';

// --- Configuration ---
const String notificationChannelId = 'tether_background_service_channel';
const String notificationChannelName = 'Tether Background Service';
const String notificationChannelDescription =
    'Handles background tasks for Tether.';
const int backgroundServiceNotificationId = 888999; // Unique ID

// --- User-defined Callbacks & Job Handlers ---

/// Signature for the application-specific initialization callback.
///
/// This function is executed in the background isolate when the service starts.
/// It's responsible for initializing any resources needed by the background tasks,
/// such as database connections (for the background isolate), Supabase client,
/// or Riverpod containers. It must also register all job handlers using
/// [BackgroundService.registerJobHandler] and set the background
/// database connection using [BackgroundService.setBackgroundDbConnection].
///
/// The [service] parameter provides an instance of [ServiceInstance] for
/// interacting with the background service from within this callback.
typedef AppInitializationCallback =
    Future<void> Function(ServiceInstance service);

/// Signature for a job handler function.
///
/// Job handlers are responsible for executing the actual background task
/// associated with a `jobKey`.
///
/// - [service]: The [ServiceInstance] for interacting with the background service.
/// - [payload]: An optional [Map<String, dynamic>] containing data for the job.
/// - [db]: The [SqliteConnection] for the background isolate, provided by
///   [BackgroundService] after it's set in [AppInitializationCallback].
typedef JobHandler =
    Future<void> Function(
      ServiceInstance service,
      Map<String, dynamic>? payload,
      SqliteConnection db,
    );

/// Manages a generic background service capable of running arbitrary Dart functions.
///
/// This service uses a local SQLite database (`background_service_jobs` table)
/// as a job queue. Tasks are enqueued from the main UI isolate and processed
/// by the background service.
///
/// ## Setup
/// 1. **Initialize the service:** Call [BackgroundService.initialize] once,
///    typically in your `main()` function. Provide an [AppInitializationCallback].
/// 2. **Implement `AppInitializationCallback`:**
///    - Initialize resources needed by background tasks (e.g., database connection
///      for the background isolate, Supabase client).
///    - Call [BackgroundService.setBackgroundDbConnection] with the background
///      isolate's database connection.
///    - Register all job handlers using [BackgroundService.registerJobHandler].
/// 3. **Define Job Handlers:** Create functions matching the [JobHandler] signature
///    for each type of background task.
/// 4. **Enqueue Jobs:** Use [BackgroundService.job] from your UI isolate
///    to add tasks to the queue.
///
/// ## Android Configuration
/// Ensure your `AndroidManifest.xml` is configured for foreground services as per
/// the `flutter_background_service` plugin documentation. This includes adding
/// necessary permissions and the service declaration.
///
/// ## iOS Configuration
/// Follow `flutter_background_service` documentation for `Info.plist` and
/// `AppDelegate.swift` modifications if background fetch or custom task
/// identifiers are needed. Note that iOS has limitations on long-running
/// background tasks.
class BackgroundService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static final Map<String, JobHandler> _jobHandlers = {};
  static AppInitializationCallback? _appInitializationCallback;

  /// The [SqliteConnection] used by the background isolate.
  /// This is set by the user's [AppInitializationCallback] via
  /// [BackgroundService.setBackgroundDbConnection].
  static SqliteConnection?
  _backgroundDbConnection; // DB connection for the background isolate

  /// Checks if the background service is currently running.
  ///
  /// Returns `true` if the service is active, `false` otherwise.
  static Future<bool> isRunning() => _service.isRunning();

  /// Registers a [JobHandler] for a specific `jobKey`.
  ///
  /// When a job with this `key` is processed from the queue, the provided
  /// [handler] will be executed. This should be called within the
  /// [AppInitializationCallback].
  ///
  /// ```dart
  /// // In your AppInitializationCallback:
  /// GenericBackgroundService.registerJobHandler('syncUserData', _handleUserSync);
  /// GenericBackgroundService.registerJobHandler('processImage', _handleImageProcessing);
  /// ```
  static void registerJobHandler(String key, JobHandler handler) {
    _jobHandlers[key] = handler;
    log('BackgroundService: Registered job handler for key "$key"');
  }

  /// Sets the [SqliteConnection] to be used by the background isolate.
  ///
  /// This **must** be called by the user-provided [AppInitializationCallback]
  /// after a database connection has been established for the background isolate.
  ///
  /// ```dart
  /// // In your AppInitializationCallback:
  /// @pragma('vm:entry-point')
  /// Future<void> _myAppBackgroundInit(ServiceInstance service) async {
  ///   final backgroundDb = await AppDatabase().openNewConnection(); // Open DB for this isolate
  ///   GenericBackgroundService.setBackgroundDbConnection(backgroundDb);
  ///   // ... rest of initialization ...
  /// }
  /// ```
  static void setBackgroundDbConnection(SqliteConnection db) {
    BackgroundService._backgroundDbConnection = db;
    log("BackgroundService: Background DB connection has been set.");
  }

  /// Initializes the background service.
  ///
  /// This method should be called once, typically in your application's `main()`
  /// function, before `runApp()`.
  ///
  /// - [appInitializationCallback]: A user-defined function that will be executed
  ///   in the background isolate when the service starts. It's responsible for
  ///   setting up resources and registering job handlers. See [AppInitializationCallback].
  /// - [initialNotificationTitle]: The title for the persistent notification
  ///   displayed on Android when the service is in foreground mode.
  /// - [initialNotificationContent]: The content text for the persistent notification.
  /// - [notificationIconName]: (Android only) The name of the drawable resource for
  //    the notification icon (e.g., 'ic_bg_service_small'). Ensure this icon
  ///   exists in your `android/app/src/main/res/drawable-*` folders.
  ///
  /// ```dart
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   await GenericBackgroundService.initialize(
  ///     appInitializationCallback: _myAppBackgroundInit,
  ///     initialNotificationTitle: "My App Service",
  ///     initialNotificationContent: "Processing background tasks...",
  ///   );
  ///
  ///   runApp(MyApp());
  /// }
  ///
  /// @pragma('vm:entry-point')
  /// Future<void> _myAppBackgroundInit(ServiceInstance service) async {
  ///   // Initialize DB for background isolate
  ///   final db = await AppDatabase().openNewConnection();
  ///   GenericBackgroundService.setBackgroundDbConnection(db);
  ///
  ///   // Register handlers
  ///   GenericBackgroundService.registerJobHandler('myTask', _myTaskHandler);
  /// }
  /// ```
  static Future<void> initialize({
    required AppInitializationCallback appInitializationCallback,
    String initialNotificationTitle = 'Background Service',
    String initialNotificationContent = 'Processing tasks...',
    String? notificationIconName, // e.g., 'ic_bg_service_small'
  }) async {
    _appInitializationCallback = appInitializationCallback;

    // Android Notification Channel (Optional, but good for customization)
    // If you use flutter_local_notifications, create channel there.
    // This is a basic setup if not using a separate notification plugin.

    await _service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        isForegroundMode: true, // Recommended for reliability
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: initialNotificationTitle,
        initialNotificationContent: initialNotificationContent,
        foregroundServiceNotificationId: backgroundServiceNotificationId,
        // Optional: if you have a custom icon in android/app/src/main/res/drawable
        // notificationIcon: notificationIconName != null
        //     ? AndroidResource(name: notificationIconName, defType: 'drawable')
        //     : null,
      ),
    );
    log('BackgroundService: Configured.');
  }

  static Future<void> start() async {
    if (!await _service.isRunning()) {
      await _service.startService();
      log('BackgroundService: Started.');
    }
  }

  /// Stops the background service.
  ///
  /// This will signal the processing loop to cease and then stop the service itself.
  /// It also attempts to close the background database connection.
  static Future<void> stop() async {
    if (await _service.isRunning()) {
      _service.invoke("stopProcessing"); // Signal processing loop to stop
      // Give it a moment to process the stop signal before stopping the service itself
      await Future.delayed(const Duration(seconds: 1));
      _service.invoke(
        "stopSelf",
      ); // This is an internal command for the service
      log('BackgroundService: Stop requested.');
    }
  }

  /// Enqueues a new job to be processed by the background service.
  ///
  /// This method should be called from the main UI isolate.
  ///
  /// - [db]: The [SqliteConnection] of the main UI isolate. This is used to
  ///   insert the job record into the `background_service_jobs` table.
  /// - [jobKey]: A string identifier for the task. A [JobHandler] must be
  ///   registered for this key via [registerJobHandler].
  /// - [payload]: Optional data for the job, as a `Map<String, dynamic>`.
  ///   This will be JSON-encoded and stored in the database.
  /// - [priority]: An integer for job prioritization (higher values are processed first).
  ///   Currently, this is a basic implementation; more complex prioritization might
  ///   require adjustments to the job fetching query.
  /// - [maxAttempts]: The maximum number of times a job will be retried if it fails.
  ///
  /// Returns the ID of the newly inserted job row if successful, otherwise `null`.
  ///
  /// ```dart
  /// // Assuming 'mainDbConnection' is the SqliteConnection for the UI isolate
  /// await GenericBackgroundService.enqueueJob(
  ///   db: mainDbConnection,
  ///   jobKey: 'syncUserData',
  ///   payload: {'userId': '123', 'forceFullSync': true},
  /// );
  /// ```
  static Future<int?> job({
    required SqliteConnection db, // Pass the main isolate's DB connection
    required String jobKey,
    Map<String, dynamic>? payload,
    int priority = 0,
    int maxAttempts = 3,
  }) async {
    if (!_jobHandlers.containsKey(jobKey)) {
      log(
        'BackgroundService: Error - No handler registered for job key "$jobKey".',
      );
      return null;
    }
    try {
      final String? encodedPayload =
          payload != null ? jsonEncode(payload) : null;
      final result = await db.execute(
        '''
        INSERT INTO background_service_jobs (job_key, payload, priority, max_attempts, status)
        VALUES (?, ?, ?, ?, 'PENDING')
        ''',
        [jobKey, encodedPayload, priority, maxAttempts],
      );
      log(
        'BackgroundService: Enqueued job "$jobKey" with ID $result. Payload: $encodedPayload',
      );
      // Signal the service to check for new jobs if it's running
      if (await _service.isRunning()) {
        _service.invoke('newJobAvailable');
      }
      return result.length;
    } catch (e, s) {
      log('BackgroundService: Error enqueuing job "$jobKey": $e\n$s');
      return null;
    }
  }
}

// --- Background Isolate Entry Points ---

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  log('BackgroundService (iOS): onIosBackground triggered.');
  // Limited execution time on iOS. You might trigger a short task or check.
  // For longer tasks, it's complex and relies on BGTaskScheduler.
  // This basic setup won't run the full job processing loop continuously on iOS background.
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized(); // Essential for plugins in background
  log(
    'BackgroundService: onStart triggered. ServiceInstance Hash: ${service.hashCode}',
  );

  bool processingEnabled = true;
  Timer? jobCheckTimer;
  BackgroundJobManager? jobManager; // Declare manager instance variable

  if (BackgroundService._appInitializationCallback == null) {
    log(
      'BackgroundService: Error - AppInitializationCallback not set. Cannot proceed.',
    );
    service.stopSelf();
    return;
  }

  try {
    // --- 1. Execute User's App Initialization ---
    await BackgroundService._appInitializationCallback!(service);
    log('BackgroundService: App initialization callback completed.');

    if (BackgroundService._backgroundDbConnection == null) {
      log(
        'BackgroundService: CRITICAL - _backgroundDbConnection not set by appInitializationCallback. Job processing cannot start.',
      );
      service.stopSelf();
      return;
    }

    // Instantiate the BackgroundJobManager
    jobManager = BackgroundJobManager(
      db: BackgroundService._backgroundDbConnection!,
    );
    log('BackgroundService: BackgroundJobManager instantiated.');

    // --- 2. Service Event Listeners ---
    service.on('stopProcessing').listen((event) {
      log('BackgroundService: Received "stopProcessing" command.');
      processingEnabled = false;
      jobCheckTimer?.cancel();
    });

    service.on('stopSelf').listen((event) async {
      log('BackgroundService: Received "stopSelf" command.');
      processingEnabled = false;
      jobCheckTimer?.cancel();
      await BackgroundService._backgroundDbConnection?.close();
      BackgroundService._backgroundDbConnection = null;
      jobManager = null; // Clear the manager instance
      service.stopSelf(); // Actual service stop
      log('BackgroundService: Stopped.');
    });

    service.on('newJobAvailable').listen((event) {
      log(
        'BackgroundService: Received "newJobAvailable" signal. Will process soon.',
      );
    });

    // --- 3. Main Job Processing Loop (Timer-based) ---
    Future<void> processPendingJobs(
      ServiceInstance service,
      // SqliteConnection db, // Replaced by manager for job queue operations
      BackgroundJobManager manager, // Pass the manager instance
    ) async {
      if (!processingEnabled) return;
      log('BackgroundService: Checking for pending jobs...');

      List<BackgroundJob> pendingJobs;
      try {
        // Fetch using BackgroundJobManager.
        // NOTE: The original query was "ORDER BY priority DESC, created_at ASC".
        // The manager's getJobsByStatus sorts by "created_at ASC" by default.
        // This means priority is not currently the primary sort key when using this manager method.
        pendingJobs = await manager.getJobsByStatus(
          BackgroundJobStatus.pending,
          limit: 1, // Process one job at a time
          orderByCreation: 'ASC',
        );
      } catch (e, s) {
        log(
          'BackgroundService: Error querying for pending jobs via manager: $e\n$s',
        );
        return;
      }

      if (pendingJobs.isEmpty) {
        // log('BackgroundService: No pending jobs found.');
        return;
      }

      BackgroundJob job = pendingJobs.first;
      log('BackgroundService: Found job: ID=${job.id}, Key=${job.jobKey}');

      final handler = BackgroundService._jobHandlers[job.jobKey];
      if (handler == null) {
        log(
          'BackgroundService: No handler for job key "${job.jobKey}". Marking as FAILED.',
        );
        // Manually update attempts as manager's updateJobStatus doesn't handle it.
        final currentAttempts = job.attempts + 1;
        await BackgroundService._backgroundDbConnection!.execute(
          "UPDATE background_service_jobs SET attempts = ? WHERE id = ?",
          [currentAttempts, job.id],
        );
        await manager.updateJobStatus(
          job.id,
          BackgroundJobStatus.failed,
          lastError: 'No handler registered.',
        );
        return;
      }

      // Mark as RUNNING and increment attempts
      final updatedAttempts = job.attempts + 1;
      // Update attempts directly using the DB connection
      await BackgroundService._backgroundDbConnection!.execute(
        "UPDATE background_service_jobs SET attempts = ? WHERE id = ?",
        [updatedAttempts, job.id],
      );
      // Then update status using the manager
      await manager.updateJobStatus(job.id, BackgroundJobStatus.running);
      // Create an updated local job object if its state is needed further in this scope
      job = job.copyWith(
        status: BackgroundJobStatus.running,
        attempts: updatedAttempts,
        lastAttemptAt: DateTime.now(),
      );

      // Update notification (optional)
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Processing: ${job.jobKey}",
            content: "Job ID: ${job.id} - Attempt $updatedAttempts",
          );
        }
      }

      try {
        // The handler still needs direct DB access for its own operations, not related to job queue management.
        await handler(
          service,
          job.payload,
          BackgroundService._backgroundDbConnection!,
        );
        await manager.updateJobStatus(job.id, BackgroundJobStatus.completed);
        log('BackgroundService: Job ID=${job.id} (${job.jobKey}) COMPLETED.');
      } catch (e, s) {
        log(
          'BackgroundService: Error executing job ID=${job.id} (${job.jobKey}): $e\n$s',
        );
        if (updatedAttempts >= job.maxAttempts) {
          await manager.updateJobStatus(
            job.id,
            BackgroundJobStatus.failed,
            lastError: e.toString(),
          );
          log(
            'BackgroundService: Job ID=${job.id} (${job.jobKey}) FAILED permanently after $updatedAttempts attempts.',
          );
        } else {
          // Revert to PENDING for retry
          await manager.updateJobStatus(
            job.id,
            BackgroundJobStatus.pending,
            lastError: e.toString(),
          );
          log(
            'BackgroundService: Job ID=${job.id} (${job.jobKey}) attempt failed. Will retry.',
          );
        }
      } finally {
        // Reset notification to generic (optional)
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            service.setForegroundNotificationInfo(
              title: "Background Service Active", // Or your initial title
              content: "Waiting for tasks...", // Or your initial content
            );
          }
        }
      }
    }

    // Start the timer
    jobCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!processingEnabled) {
        timer.cancel();
        return;
      }
      // Ensure jobManager is not null before using it
      if (jobManager != null &&
          BackgroundService._backgroundDbConnection != null) {
        try {
          await processPendingJobs(
            service,
            jobManager!,
          ); // Pass the manager instance
        } catch (e, s) {
          log(
            "BackgroundService: Error during timed processPendingJobs (DB likely closed or issue): $e\n$s",
          );
        }
      } else {
        log(
          "BackgroundService: DB connection or JobManager is null. Cannot process jobs.",
        );
      }
    });

    // Initial check
    // Ensure jobManager is not null
    if (jobManager != null &&
        BackgroundService._backgroundDbConnection != null) {
      try {
        await processPendingJobs(
          service,
          jobManager!,
        ); // Pass the manager instance
      } catch (e, s) {
        log(
          "BackgroundService: Error during initial processPendingJobs (DB likely closed or issue): $e\n$s",
        );
      }
    }

    log('BackgroundService: Processing loop started.');
  } catch (e, s) {
    log('BackgroundService: FATAL ERROR in onStart: $e\n$s');
    service.stopSelf(); // Stop service on fatal error during init
  }
}
