// background_query_service.dart
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For PostgrestBuilder
// Import your SupabaseBackgroundTaskDetails and onStart
// import 'serializable_task_details.dart'; // Adjust path
// import 'background_service_handler.dart'; // Adjust path

// Provider for the service controller
final backgroundQueryServiceProvider =
    Provider<BackgroundQueryServiceController>((ref) {
      return BackgroundQueryServiceController(ref);
    });

// Provider for task updates stream
final taskUpdatesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final controller = ref.watch(backgroundQueryServiceProvider);
  return controller.taskUpdatesStream;
});

class BackgroundQueryServiceController {
  final Ref _ref;
  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isServiceInitialized = false;
  bool _isServiceRunning = false;

  final _taskUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get taskUpdatesStream =>
      _taskUpdatesController.stream;

  BackgroundQueryServiceController(this._ref) {
    _service.on('taskUpdate').listen((event) {
      if (event != null) {
        _taskUpdatesController.add(event);
      }
    });
    _service.on('heartbeat').listen((event) {
      print("Foreground: Received heartbeat: $event");
    });
  }

  Future<void> initializeService() async {
    if (_isServiceInitialized) return;
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // Your top-level background entry point
        autoStart: false, // We'll start it manually
        isForegroundMode: true, // Or false, depending on needs
        notificationChannelId: 'background_query_service',
        initialNotificationTitle: 'Background Query Service',
        initialNotificationContent: 'Executing tasks...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false, // We'll start it manually
        onForeground: onStart,
        onBackground: onStart, // Or a different handler if needed
      ),
    );
    _isServiceInitialized = true;
    print("BackgroundQueryServiceController: Service initialized.");
  }

  Future<void> startServiceIfNotRunning() async {
    if (!_isServiceInitialized) {
      await initializeService();
    }
    _isServiceRunning = await _service.isRunning();
    if (!_isServiceRunning) {
      await _service.startService();
      _isServiceRunning = true;
      print("BackgroundQueryServiceController: Service started.");
    } else {
      print("BackgroundQueryServiceController: Service already running.");
    }
  }

  Future<void> stopService() async {
    _isServiceRunning = await _service.isRunning();
    if (_isServiceRunning) {
      _service.invoke(
        "stopService",
      ); // If you have a handler for this in onStart
      _isServiceRunning = false;
      print("BackgroundQueryServiceController: Service stopped.");
    }
  }

  /// Executes a Supabase query (defined by the PostgrestBuilder) in the background.
  ///
  /// - `builder`: The PostgrestBuilder from your ClientManager or Supabase client.
  /// - `taskId`: A unique ID for this task so you can correlate updates.
  /// - `fromJsonFactory`: The function to deserialize the raw JSON data from Supabase.
  Future<void> executeSupabaseTaskInBackground({
    required PostgrestBuilder builder,
    required String taskId,
    // The fromJsonFactory will be used by the UI when it receives the raw data
  }) async {
    await startServiceIfNotRunning(); // Ensure service is running

    final taskDetails = SupabaseBackgroundTaskDetails.fromPostgrestBuilder(
      builder,
      taskId: taskId,
    );

    _service.invoke('executeTask', taskDetails.toJson());
    print("BackgroundQueryServiceController: Invoked executeTask for $taskId.");
  }

  void dispose() {
    _taskUpdatesController.close();
  }
}
