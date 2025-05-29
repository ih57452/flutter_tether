import 'package:supabase_flutter/supabase_flutter.dart'; // For PostgresChangeFilterType

/// Defines the type of filter to be applied to the realtime stream.
/// Mirrors Supabase's PostgresChangeFilterType for consistency.
enum RealtimeManagerFilterType { eq, neq, lt, lte, gt, gte, inFilter }

extension RealtimeManagerFilterTypeToSupabase on RealtimeManagerFilterType {
  PostgresChangeFilterType toSupabaseFilterType() {
    switch (this) {
      case RealtimeManagerFilterType.eq:
        return PostgresChangeFilterType.eq;
      case RealtimeManagerFilterType.neq:
        return PostgresChangeFilterType.neq;
      case RealtimeManagerFilterType.lt:
        return PostgresChangeFilterType.lt;
      case RealtimeManagerFilterType.lte:
        return PostgresChangeFilterType.lte;
      case RealtimeManagerFilterType.gt:
        return PostgresChangeFilterType.gt;
      case RealtimeManagerFilterType.gte:
        return PostgresChangeFilterType.gte;
      case RealtimeManagerFilterType.inFilter:
        return PostgresChangeFilterType.inFilter;
    }
  }
}

class RealtimeManagerFilterConfig {
  final String column;
  final dynamic value;
  final RealtimeManagerFilterType type;

  RealtimeManagerFilterConfig({
    required this.column,
    required this.value,
    required this.type,
  });
}

class RealtimeManagerOrderConfig {
  final String column;
  final bool ascending;

  RealtimeManagerOrderConfig({required this.column, this.ascending = true});
}
