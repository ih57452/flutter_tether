import 'dart:convert';
import 'dart:developer';

enum BackgroundJobStatus { pending, running, completed, failed }

class BackgroundJob {
  final int id;
  final String jobKey;
  final Map<String, dynamic>? payload;
  final BackgroundJobStatus status;
  final int attempts;
  final int maxAttempts;
  final DateTime? lastAttemptAt;
  final String? lastError;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  BackgroundJob({
    required this.id,
    required this.jobKey,
    this.payload,
    required this.status,
    required this.attempts,
    required this.maxAttempts,
    this.lastAttemptAt,
    this.lastError,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BackgroundJob.fromMap(Map<String, dynamic> map) {
    dynamic decodedPayload;
    if (map['payload'] != null) {
      try {
        decodedPayload = jsonDecode(map['payload'] as String);
      } catch (e) {
        // If payload is not valid JSON, store as null or handle error
        log('Error decoding job payload for job id ${map['id']}: $e');
        decodedPayload = null;
      }
    }

    return BackgroundJob(
      id: map['id'] as int,
      jobKey: map['job_key'] as String,
      payload: decodedPayload as Map<String, dynamic>?,
      status: BackgroundJobStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String).toLowerCase(),
        orElse: () => BackgroundJobStatus.pending,
      ),
      attempts: map['attempts'] as int,
      maxAttempts: map['max_attempts'] as int? ?? 3, // Default if not in DB
      lastAttemptAt:
          map['last_attempt_at'] == null
              ? null
              : DateTime.tryParse(map['last_attempt_at'] as String),
      lastError: map['last_error'] as String?,
      priority: map['priority'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMapForDbUpdate() {
    return {
      'id': id,
      'status': status.name.toUpperCase(),
      'attempts': attempts,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'last_error': lastError,
      // updated_at is handled by trigger
    };
  }

  BackgroundJob copyWith({
    int? id,
    String? jobKey,
    Map<String, dynamic>? payload,
    BackgroundJobStatus? status,
    int? attempts,
    int? maxAttempts,
    DateTime? lastAttemptAt,
    String? lastError,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BackgroundJob(
      id: id ?? this.id,
      jobKey: jobKey ?? this.jobKey,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
