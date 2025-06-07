import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/database/models.g.dart';
import 'package:example/database/providers/feed_provider.dart';
import 'package:example/database/supabase_select_builders.g.dart';
import 'package:example/models/selects.dart';
import 'package:example/database/managers/books_client_manager.g.dart';
import 'package:example/database/managers/genres_client_manager.g.dart';
import 'package:tether_libs/client_manager/manager/client_manager_filter_builder.dart';

// Provider to fetch all genres
final allGenresProvider = FutureProvider<List<GenreModel>>((ref) async {
  final genresManager = ref.watch(genresManagerProvider);
  // Assuming a method like getAll() or query().getAll() exists
  // For this example, let's assume it fetches all genres without specific filters.
  // You might need to adjust this based on your ClientManager capabilities.
  return await genresManager.query.select(genreSelect).remoteOnly();
});

class StringNotifier extends Notifier<String?> {
  StringNotifier() : super();

  @override
  String? build() {
    return null; // Initial state is null, meaning no genre selected
  }

  void set(String? newString) {
    state = newString;
  }
}

// Provider to manage the selected genre ID.
final selectedGenreIdProvider = NotifierProvider<StringNotifier, String?>(
  StringNotifier.new,
); // Starts with no genre selected

// Update bookFeedProvider to use the selected genre's book IDs in queryCustomizer
final bookFeedProvider = Provider<FeedStreamNotifierSettings<BookModel>>((ref) {
  final bookClientManager = ref.watch(booksManagerProvider);
  final selectedGenreId = ref.watch(
    selectedGenreIdProvider,
  ); // Read current selection

  // This function will be the queryCustomizer. It captures the current bookIdsAsyncValue.
  // When bookIdsAsyncValue changes, bookFeedProvider re-evaluates, creating new settings
  // with a new queryCustomizer instance.
  ClientManagerFilterBuilder<BookModel> queryCustomizer(
    ClientManagerFilterBuilder<BookModel> baseQuery,
  ) {
    if (selectedGenreId == null) {
      // No genre selected, apply no genre-specific filter.
      return baseQuery;
    }

    return baseQuery.eq(BookGenresColumn.genreId, selectedGenreId);
  }

  return FeedStreamNotifierSettings<BookModel>(
    // Consider if feedKey needs to be dynamic if queryCustomizer changes fundamentally
    // e.g., feedKey: 'books_feed_genre_${ref.watch(selectedGenreIdProvider) ?? "all"}'
    // For now, a static key means the notifier might try to reuse cache, but a new
    // queryCustomizer should trigger a full refresh from page 1.
    feedKey: 'books_feed_customized_by_genre',
    clientManager: bookClientManager,
    selectArgs: bookSelect,
    fromJsonFactory: BookModel.fromJson,
    pageSize: 20,
    queryCustomizer:
        queryCustomizer, // Assign the dynamically created customizer
  );
});

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Initial data load will be triggered by the FeedStreamNotifier
    // when it's first watched, using the initial queryCustomizer.
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    if (_isFetchingMore) return;
    setState(() => _isFetchingMore = true);

    // Watch the reactive bookFeedProvider to get current settings
    final settings = ref.read(bookFeedProvider);
    final notifier = ref.read(booksFeedProvider(settings).notifier);
    await notifier.fetchMoreItems();

    if (mounted) {
      setState(() => _isFetchingMore = false);
    }
  }

  void _updateSelectedGenre(String? genreId) {
    ref.read(selectedGenreIdProvider.notifier).set(genreId);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the reactive bookFeedProvider to get current settings
    final settings = ref.watch(bookFeedProvider);
    // Pass these potentially changing settings to the booksFeedProvider family
    final booksAsyncValue = ref.watch(booksFeedProvider(settings));
    final genresAsyncValue = ref.watch(allGenresProvider);
    final currentSelectedGenreId = ref.watch(selectedGenreIdProvider);

    return Column(
      children: [
        // Genre Filter Section
        genresAsyncValue.when(
          data: (genres) {
            if (genres.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ChoiceChip(
                    label: const Text('All Genres'),
                    selected: currentSelectedGenreId == null,
                    onSelected:
                        (_) => _updateSelectedGenre(null), // Use new method
                  ),
                  ...genres.map((genre) {
                    return ChoiceChip(
                      label: Text(genre.name),
                      selected: currentSelectedGenreId == genre.id,
                      onSelected:
                          (_) =>
                              _updateSelectedGenre(genre.id), // Use new method
                    );
                  }),
                ],
              ),
            );
          },
          loading:
              () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
          error:
              (err, stack) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Error loading genres: $err'),
              ),
        ),

        // Books List Section
        Expanded(
          child: booksAsyncValue.when(
            data: (bookList) {
              if (bookList.isEmpty && !booksAsyncValue.isLoading) {
                return Center(
                  child: Text(
                    currentSelectedGenreId == null
                        ? 'No books available.'
                        : 'No books found for the selected genre.',
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: bookList.length + (_isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == bookList.length && _isFetchingMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (index >= bookList.length) {
                    return const SizedBox.shrink();
                  }

                  final book = bookList[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text(
                      'Author: ${book.author?.firstName ?? 'N/A'} ${book.author?.lastName ?? ''}\n'
                      'Genres: ${book.bookGenres?.map((bg) => bg.genre?.name ?? 'N/A').join(', ') ?? 'N/A'}',
                    ),
                    isThreeLine: true,
                    // You can add onTap to navigate to book details
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, stack) =>
                    Center(child: Text('Error loading books: $err')),
          ),
        ),
      ],
    );
  }
}
