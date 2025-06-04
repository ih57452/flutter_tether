import 'package:example/database/managers/books_client_manager.g.dart';
import 'package:example/database/models.g.dart';
import 'package:example/database/providers/feed_provider.dart';
import 'package:example/database/supabase_select_builders.g.dart';
import 'package:example/models/selects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookSearchSettingsProvider = Provider<
  FeedStreamNotifierSettings<BookModel>
>((ref) {
  final bookClientManager = ref.watch(booksManagerProvider);
  return FeedStreamNotifierSettings<BookModel>(
    feedKey: 'books_search_feed',
    searchColumn: BooksColumn.document,
    clientManager: bookClientManager,
    selectArgs: bookSelect, // Use your stable bookSelect instance
    fromJsonFactory: BookModel.fromJson, // Static method
    pageSize: 20,
    // queryCustomizer: (baseQuery) => baseQuery.eq(BooksColumn.someField, someStableValue), // If needed
  );
});

class SearchFeedTab extends ConsumerStatefulWidget {
  const SearchFeedTab({super.key});

  @override
  ConsumerState<SearchFeedTab> createState() => _SearchFeedTabState();
}

class _SearchFeedTabState extends ConsumerState<SearchFeedTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // 1. Add ScrollController
  String _searchTerm = '';
  bool _isFetchingMore = false; // To prevent multiple fetch calls

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Debounce search logic can be added here
      // For now, direct search on submit or button press
    });

    // 2. Add listener to ScrollController
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener); // 3. Remove listener
    _scrollController.dispose(); // 3. Dispose controller
    super.dispose();
  }

  void _scrollListener() {
    // Check if we're near the end of the scroll extent
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                200 && // 200px threshold
        !_isFetchingMore) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    // Get the notifier instance for the current provider settings
    // Note: It's important that 'provider' here is the same instance
    // or an equivalent one that refers to the currently active notifier.
    final settings = ref.read(bookSearchSettingsProvider);
    final notifier = ref.read(booksFeedProvider(settings).notifier);

    // print("Fetching more items..."); // For debugging
    await notifier.fetchMoreItems();

    if (mounted) {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  void _performSearch() {
    _searchTerm = _searchController.text;
    // Get the notifier instance for the current provider settings
    final settings = ref.read(bookSearchSettingsProvider);
    final notifier = ref.read(booksFeedProvider(settings).notifier);
    notifier.search(_searchTerm); // Call search on the notifier
    // print("Searching for: $_searchTerm");
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(bookSearchSettingsProvider);
    final asyncValue = ref.watch(booksFeedProvider(settings));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Books (Full-Text)',
              hintText: 'Enter title, description, tags...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        Expanded(
          child: asyncValue.when(
            data: (stream) {
              if (stream.isEmpty &&
                  _searchTerm.isNotEmpty &&
                  !asyncValue.isLoading) {
                return const Center(child: Text('No books found.'));
              }
              if (stream.isEmpty &&
                  _searchTerm.isEmpty &&
                  !asyncValue.isLoading) {
                // You might want to show a message or a different UI
                // if the initial feed is empty before any search.
                // Or trigger an initial fetch if not done by the provider.
                return const Center(child: Text('No books available.'));
              }
              return ListView.builder(
                controller:
                    _scrollController, // 4. Assign controller to ListView
                itemCount:
                    stream.length +
                    (_isFetchingMore ? 1 : 0), // Add space for loader
                itemBuilder: (context, index) {
                  if (index == stream.length && _isFetchingMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (index >= stream.length) {
                    return const SizedBox.shrink(); // Should not happen if itemCount is correct
                  }

                  final book = stream[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text(
                      '${book.author?.firstName ?? 'Unknown'} ${book.author?.lastName ?? ''}',
                    ),
                    // Add more details or an onTap handler
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
