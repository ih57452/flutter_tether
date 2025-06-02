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
    final jobIdForLog = map.containsKey('id') && map['id'] != null
        ? map['id'].toString()
        : 'unknown_id';

    Map<String, dynamic>? decodedPayload;
    final rawPayload = map['payload'];
    if (rawPayload != null) {
      if (rawPayload is String) {
        try {
          final jsonData = jsonDecode(rawPayload);
          if (jsonData is Map<String, dynamic>) {
            decodedPayload = jsonData;
          } else {
            log('Warning: Decoded JSON payload for job id $jobIdForLog is not a Map<String, dynamic>. Type: ${jsonData.runtimeType}');
          }
        } catch (e) {
          log('Error decoding JSON string payload for job id $jobIdForLog: $e. Payload: $rawPayload');
        }
      } else if (rawPayload is Map<String, dynamic>) {
        decodedPayload = rawPayload;
      } else {
        log('Warning: Payload for job id $jobIdForLog is not a JSON string or a Map. Type: ${rawPayload.runtimeType}. Payload: $rawPayload');
      }
    }

    BackgroundJobStatus statusValue;
    final rawStatus = map['status'];
    if (rawStatus is String) {
      statusValue = BackgroundJobStatus.values.firstWhere(
        (e) => e.name == rawStatus.toLowerCase(),
        orElse: () {
          log('Warning: Unknown status string "$rawStatus" for job id $jobIdForLog. Defaulting to pending.');
          return BackgroundJobStatus.pending;
        },
      );
    } else {
      log('Warning: Status field for job id $jobIdForLog is not a string or is null (value: $rawStatus). Defaulting to pending.');
      statusValue = BackgroundJobStatus.pending;
    }

    DateTime? parsedLastAttemptAt;
    final rawLastAttemptAt = map['last_attempt_at'];
    if (rawLastAttemptAt is String) {
      parsedLastAttemptAt = DateTime.tryParse(rawLastAttemptAt);
      if (parsedLastAttemptAt == null && rawLastAttemptAt.isNotEmpty) {
        log('Warning: Could not parse last_attempt_at string "$rawLastAttemptAt" for job id $jobIdForLog.');
      }
    } else if (rawLastAttemptAt != null) {
      log('Warning: last_attempt_at for job id $jobIdForLog was not a String (type: ${rawLastAttemptAt.runtimeType}, value: $rawLastAttemptAt). Interpreting as null.');
    }

    return BackgroundJob(
      id: map['id'] as int,
      jobKey: map['job_key'] as String,
      payload: decodedPayload,
      status: statusValue,
      attempts: map['attempts'] as int,
      maxAttempts: map['max_attempts'] as int? ?? 3, // Default if not in DB or not an int
      lastAttemptAt: parsedLastAttemptAt,
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
