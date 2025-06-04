import 'package:example/database/managers/genres_client_manager.g.dart';
import 'package:example/database/supabase_select_builders.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final realtimeProvider = StreamProvider.autoDispose((ref) {
  final genresManager = ref.watch(genresManagerProvider);

  return genresManager
      .realtime()
      .eq(
        GenresColumn.id,
        'example-genre-id',
      ) // Replace with your actual column and value
      .order(GenresColumn.name, ascending: true)
      .listen();
});
