// background_service_handler.dart
import 'dart:async';
import 'dart:ui'; // For DartPluginRegistrant
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tether_background_runner/background_runner/background_task_details.dart';
// Import your SupabaseBackgroundTaskDetails
// import 'serializable_task_details.dart'; // Adjust path

// IMPORTANT: Replace with your actual Supabase URL and Anon Key
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized(); // For plugins

  SupabaseClient? client;

  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    client = Supabase.instance.client;
    print("Background Service: Supabase initialized.");
  } catch (e) {
    print("Background Service: Supabase initialization error: $e");
    // Optionally notify UI about initialization failure
    service.invoke('taskUpdate', {
      'taskId': 'initialization_error',
      'error': 'Supabase init failed: $e',
    });
    return; // Stop if Supabase can't init
  }

  service.on('executeTask').listen((event) async {
    if (client == null) {
      print(
        "Background Service: Supabase client not initialized. Cannot execute task.",
      );
      service.invoke('taskUpdate', {
        'taskId': event?['taskId'] ?? 'unknown_task',
        'error': 'Supabase client not initialized in background.',
      });
      return;
    }

    if (event == null) return;
    print("Background Service: Received executeTask event: $event");

    final taskDetails = BackgroundTaskDetails.fromJson(event);

    try {
      // Reconstruct the full URL for the request
      // The taskDetails.urlPath should be like "/rest/v1/your_table"
      // The taskDetails.queryParameters are the `?param1=value1&param2=value2` part
      String fullUrlPath = taskDetails.urlPath;
      if (taskDetails.queryParameters != null &&
          taskDetails.queryParameters!.isNotEmpty) {
        final queryString =
            Uri(queryParameters: taskDetails.queryParameters).query;
        fullUrlPath += '?$queryString';
      }

      // Use client.rest.request for more control or build a PostgrestQueryBuilder
      // For simplicity, let's use client.rest.request
      // Note: This bypasses some of the higher-level PostgrestBuilder abstractions
      // but is more direct for executing a pre-defined request.

      final response = await client.rest.request(
        method: RestVerb.values.firstWhere(
          (e) => e.name.toLowerCase() == taskDetails.method.toLowerCase(),
          orElse: () => RestVerb.get, // Default or throw error
        ),
        // The path should be relative to the Supabase URL, e.g., '/rest/v1/your_table'
        uri: Uri.parse(fullUrlPath), // This should be just the path and query
        data: taskDetails.body,
        headers:
            taskDetails.headers, // SupabaseClient will add Auth if not present
        // schema: taskDetails.schema, // schema is part of PostgrestClient, not directly in rest.request
      );
      // If using schema, you might need to construct PostgrestClient with schema
      // PostgrestClient(Uri.parse('${client.supabaseUrl}/rest/v1'), client.headers, schema: taskDetails.schema, httpClient: client.httpClient)

      print(
        "Background Service: Task ${taskDetails.taskId} executed. Response status: ${response.statusCode}",
      );

      service.invoke('taskUpdate', {
        'taskId': taskDetails.taskId,
        'data':
            response
                .data, // This is typically List<Map<String,dynamic>> or Map<String,dynamic>
        'statusCode': response.statusCode,
      });
    } catch (e, s) {
      print(
        "Background Service: Error executing task ${taskDetails.taskId}: $e\n$s",
      );
      service.invoke('taskUpdate', {
        'taskId': taskDetails.taskId,
        'error': e.toString(),
        'stackTrace': s.toString(),
      });
    }
  });

  // You can also periodically send keep-alive messages or other updates
  Timer.periodic(const Duration(seconds: 10), (timer) {
    service.invoke('heartbeat', {'time': DateTime.now().toIso8601String()});
  });
}
