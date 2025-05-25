// serializable_task_details.dart
import 'package:supabase_flutter/supabase_flutter.dart'; // For PostgrestBuilder_PostgrestFilterBuilder

class BackgroundTaskDetails {
  final String method;
  final String urlPath; // e.g., "/rest/v1/your_table"
  final Map<String, String> headers;
  final Map<String, dynamic>? queryParameters; // Extracted from the URL
  final dynamic body;
  final String? schema;
  final String taskId; // To identify the task

  BackgroundTaskDetails({
    required this.method,
    required this.urlPath,
    required this.headers,
    this.queryParameters,
    this.body,
    this.schema,
    required this.taskId,
  });

  // Factory to create from a PostgrestBuilder
  factory BackgroundTaskDetails.fromPostgrestBuilder(
    PostgrestBuilder builder, {
    required String taskId,
  }) {
    // Note: builder.url is a URI. We need to extract the path and query params.
    // The headers might need careful handling, especially the Authorization header.
    // SupabaseClient usually injects the Authorization header. If we reconstruct
    // the request manually, we need to ensure it's present or the background
    // SupabaseClient handles it.

    // For simplicity, we'll assume the background SupabaseClient will handle auth.
    // We mainly need the relative path and query parameters.
    final uri = builder.url;
    final Map<String, String> effectiveHeaders = Map.from(builder.headers);
    // Remove Authorization if it's going to be added by the background client
    // effectiveHeaders.removeWhere((key, value) => key.toLowerCase() == 'authorization');

    return BackgroundTaskDetails(
      method: builder.method,
      urlPath: uri.path, // e.g. /rest/v1/your_table
      queryParameters:
          uri.queryParametersAll.isNotEmpty ? uri.queryParametersAll : null,
      // Headers from the builder might include API key, but auth token is usually injected by SupabaseClient
      headers: effectiveHeaders,
      body: builder.body,
      schema: builder.schema,
      taskId: taskId,
    );
  }

  Map<String, dynamic> toJson() => {
    'method': method,
    'urlPath': urlPath,
    'headers': headers,
    'queryParameters': queryParameters,
    'body': body,
    'schema': schema,
    'taskId': taskId,
  };

  factory BackgroundTaskDetails.fromJson(Map<String, dynamic> json) =>
      BackgroundTaskDetails(
        method: json['method'] as String,
        urlPath: json['urlPath'] as String,
        headers: Map<String, String>.from(json['headers'] as Map),
        queryParameters:
            json['queryParameters'] != null
                ? Map<String, dynamic>.from(json['queryParameters'] as Map)
                : null,
        body: json['body'],
        schema: json['schema'] as String?,
        taskId: json['taskId'] as String,
      );
}
