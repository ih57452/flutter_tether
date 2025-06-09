---
sidebar_position: 1
---

# Feed Management System

Tether includes an optional, powerful Feed Management System designed to
simplify the creation and management of paginated content feeds within your
Flutter application. This system leverages a Tether-managed local SQLite table
(`feed_item_references`) to store the order and references of feed items,
combined with a Riverpod `StreamNotifier` for reactive UI updates. The system
now includes intelligent count tracking to prevent unnecessary API calls and
provide better pagination controls.

Note: This feature requires `Riverpod` to work.

It supports both regular, filterable feeds and feeds driven by full-text search.

## Core Concepts

At the heart of the feed system are two main classes:

1. **`FeedStreamNotifierSettings<TModel>`**:
   - A configuration object that defines the behavior and data source for a
     specific feed.
   - It's crucial that instances of these settings are stable (e.g., defined as
     `Provider` or `final` constants) if their parameters don't change, or
     recreated when parameters _do_ change, to ensure Riverpod correctly manages
     notifier instances. For example, if you have a feed that is filtered by
     genre, you should create a new instance of `FeedStreamNotifierSettings`
     whenever the selected genre changes. This needs to propagate through to the
     `FeedStreamNotifier` instances that use these updated settings.
   - **Key Properties**:
     - `feedKey`: A unique `String` identifier for the feed. This key is used to
       store and retrieve feed item references from the local database. Usually
       this will be per Widget, for example `books_feed_filtered` or
       `books_search_feed`.
     - `clientManager`: The `ClientManager<TModel>` instance for the data type
       of the feed items.
     - `selectArgs`: A `SupabaseSelectBuilderBase` instance defining which
       columns and relationships to fetch for each item. This should generally
       be a stable instance.
     - `fromJsonFactory`: The factory method (e.g., `YourModel.fromJson`) to
       convert JSON data into your `TModel`.
     - `pageSize`: The number of items to fetch per page (defaults to 20).
     - `queryCustomizer`: An optional function
       `ClientManagerFilterBuilder<TModel> Function(ClientManagerFilterBuilder<TModel> baseQuery)`
       that allows you to apply filters or modifications to the base query for
       the feed. This is useful for creating feeds filtered by a category,
       status, etc. To reset the filters you can pass null to this function.
     - `searchColumn`: An optional `TetherColumn` used specifically for search
       feeds, indicating which column (typically a `tsvector` column) to perform
       full-text search against.

2. **`FeedStreamNotifier<TModel>`**:
   - A `FamilyStreamNotifier` (from Riverpod) that manages the state of a feed
     based on the provided `FeedStreamNotifierSettings`.
   - It handles:
     - Fetching initial data with count tracking.
     - Fetching subsequent pages (pagination) only when more items are
       available.
     - Applying search terms (if configured).
     - Applying dynamic filters.
     - Storing item references and their order in the local
       `feed_item_references` table.
     - Streaming the ordered list of `TModel` items to the UI.
     - Tracking total remote count to prevent unnecessary API calls.

The system works by first fetching item data from your Supabase backend based on
the configuration. The `TetherClientReturn<TModel>` response includes both the
data and the total count of matching records. These references are stored
locally, and the count is tracked to enable intelligent pagination. The
`FeedStreamNotifier` then watches this local table and provides a reactive
stream of `List<TModel>`.

## Count Tracking and Pagination

The feed system now includes intelligent count tracking:

- **Total Count**: The `totalRemoteCount` tracks the total number of items
  available from the remote source
- **Smart Pagination**: The `fetchMoreItems()` method only makes API calls when
  more items are actually available
- **Efficient Loading**: Prevents unnecessary network requests when all items
  have been loaded
- **UI Integration**: Exposes `hasMoreItems` property for controlling load more
  buttons and pagination UI

## Setting up a Regular Feed

A "regular" feed is typically a list of items that can be paginated and
potentially filtered based on criteria other than full-text search (e.g., by
category, date, etc.).

### 1. Define `FeedStreamNotifierSettings`

Create a provider or a stable instance for your feed settings.

```dart
// Provider to manage the selected genre ID.
final selectedGenreIdProvider = NotifierProvider<StringNotifier, String?>(
  StringNotifier.new,
); // Starts as null, can be set to a genre ID.

// Provider for the FeedStreamNotifierSettings
final bookFeedProvider = Provider<FeedStreamNotifierSettings<BookModel>>((ref) {
  final bookClientManager = ref.watch(booksManagerProvider);
  final selectedGenreId = ref.watch(selectedGenreIdProvider);

  // queryCustomizer will be re-evaluated if selectedGenreId changes
  ClientManagerFilterBuilder<BookModel> queryCustomizer(
    ClientManagerFilterBuilder<BookModel> baseQuery,
  ) {
    if (selectedGenreId == null) {
      return baseQuery; // No genre filter
    }
    // IMPORTANT: When filtering on a many-to-many relationship like genres via a join table (book_genres),
    // ensure your selectArgs in `bookSelect` includes the necessary join
    // (e.g., BooksSelectBuilder().select().withBookGenres(BookGenresSelectBuilder().select()))
    // and then filter on the column from the join table or the target table.
    return baseQuery.eq(BookGenresColumn.genreId, selectedGenreId); // Assuming BookGenresColumn.genreId exists
  }

  return FeedStreamNotifierSettings<BookModel>(
    feedKey: 'books_feed_by_genre', // Unique key for this feed
    clientManager: bookClientManager,
    selectArgs: bookSelect, // Your predefined SupabaseSelectBuilderBase instance
    fromJsonFactory: BookModel.fromJson,
    pageSize: 20,
    queryCustomizer: queryCustomizer,
  );
});
```

### 2. Use in a Widget with Count Tracking

Consume the provider in your widget to display the feed and handle interactions
with intelligent pagination.

```dart
class FeedTab extends ConsumerStatefulWidget {
  // ...
}

class _FeedTabState extends ConsumerState<FeedTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    if (_isFetchingMore) return;
    
    final settings = ref.read(bookFeedProvider);
    final notifier = ref.read(booksFeedProvider(settings).notifier);
    
    // Check if there are more items before attempting to fetch
    if (!notifier.hasMoreItems) {
      print('No more items to load');
      return;
    }

    setState(() => _isFetchingMore = true);
    await notifier.fetchMoreItems();

    if (mounted) {
      setState(() => _isFetchingMore = false);
    }
  }

  void _updateSelectedGenre(String? genreId) {
    ref.read(selectedGenreIdProvider.notifier).set(genreId);
    // When selectedGenreIdProvider changes, bookFeedProvider will re-evaluate,
    // providing new settings to booksFeedProvider. This causes Riverpod
    // to potentially create a new notifier instance or rebuild the existing one
    // with the new settings, triggering a refresh of the feed.
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(bookFeedProvider); // Watch for settings changes
    final booksAsyncValue = ref.watch(booksFeedProvider(settings)); // Watch the feed data
    final notifier = ref.read(booksFeedProvider(settings).notifier);

    return booksAsyncValue.when(
      data: (books) => Column(
        children: [
          // Count information display
          if (notifier.totalRemoteCount != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Showing ${books.length} of ${notifier.totalRemoteCount} books',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          
          // Genre selection chips
          // ... genre selection UI ...
          
          // Books list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: books.length + (notifier.hasMoreItems ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == books.length) {
                  // Load more indicator - only shown if more items available
                  return _isFetchingMore
                      ? const Center(child: CircularProgressIndicator())
                      : TextButton(
                          onPressed: _fetchMore,
                          child: const Text('Load More'),
                        );
                }
                
                final book = books[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author?.name ?? 'Unknown Author'),
                  // ... other book details
                );
              },
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

## Setting up a Search Feed

A search feed allows users to input search terms, typically for full-text
search. This assumes that full-text search is already set up in your Supabase
database. When set up properly full-text search is fast and can provide near
real-time results.

### 1. Define `FeedStreamNotifierSettings`

Configure settings specifically for search, including the `searchColumn`.

```dart
final bookSearchSettingsProvider = Provider<FeedStreamNotifierSettings<BookModel>>((ref) {
  final bookClientManager = ref.watch(booksManagerProvider);
  return FeedStreamNotifierSettings<BookModel>(
    feedKey: 'books_search_feed', // Unique key for this search feed
    searchColumn: BooksColumn.tsvector, // The tsvector column for FTS
    clientManager: bookClientManager,
    selectArgs: bookSelect, // Your predefined SupabaseSelectBuilderBase instance
    fromJsonFactory: BookModel.fromJson,
    pageSize: 20,
    // queryCustomizer can also be used here for base filters on the search, if needed
  );
});
```

### 2. Use in a Widget with Search and Count Tracking

Consume the provider and use the notifier's `search()` method with intelligent
pagination.

```dart
class SearchFeedTab extends ConsumerStatefulWidget {
  // ...
}

class _SearchFeedTabState extends ConsumerState<SearchFeedTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    if (_isFetchingMore) return;

    final settings = ref.read(bookSearchSettingsProvider);
    final notifier = ref.read(booksFeedProvider(settings).notifier);
    
    // Check if there are more items before attempting to fetch
    if (!notifier.hasMoreItems) {
      return;
    }

    setState(() => _isFetchingMore = true);
    await notifier.fetchMoreItems();

    if (mounted) {
      setState(() => _isFetchingMore = false);
    }
  }

  void _performSearch() {
    final searchTerm = _searchController.text;
    final settings = ref.read(bookSearchSettingsProvider);
    final notifier = ref.read(booksFeedProvider(settings).notifier);
    notifier.search(searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(bookSearchSettingsProvider);
    final asyncValue = ref.watch(booksFeedProvider(settings));
    final notifier = ref.read(booksFeedProvider(settings).notifier);

    return Column(
      children: [
        // Search input
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search books...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        
        // Results
        Expanded(
          child: asyncValue.when(
            data: (books) => Column(
              children: [
                // Search results count
                if (notifier.totalRemoteCount != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${notifier.totalRemoteCount} results found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                
                // Results list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: books.length + (notifier.hasMoreItems ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == books.length) {
                        // Load more indicator
                        return _isFetchingMore
                            ? const Center(child: CircularProgressIndicator())
                            : notifier.hasMoreItems
                                ? TextButton(
                                    onPressed: _fetchMore,
                                    child: const Text('Load More Results'),
                                  )
                                : const SizedBox.shrink();
                      }
                      
                      final book = books[index];
                      return ListTile(
                        title: Text(book.title),
                        subtitle: Text(book.author?.name ?? 'Unknown Author'),
                        // ... other book details
                      );
                    },
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

## Key Features & Usage Notes

- **Local Caching of Feed Structure**: The `feed_item_references` table stores
  the `feed_key`, the source table of the item, the item's ID, and its display
  order. This allows for persistent, ordered feeds. The actual item data is
  fetched based on these references and also benefits from the `ClientManager`'s
  local caching of individual models.
- **Intelligent Count Tracking**: The system tracks the total number of
  available items and prevents unnecessary API calls when all items have been
  loaded.
- **Smart Pagination**: The `fetchMoreItems()` method only makes API calls when
  more items are actually available, improving performance and user experience.
- **Count Information Access**: Use `notifier.totalRemoteCount` to get the total
  count and `notifier.hasMoreItems` to check if more items are available.
- **`feedKey` Importance**: Ensure each distinct feed in your application uses a
  unique `feedKey`. This prevents data from different feeds from mixing in the
  local `feed_item_references` table.
- **Riverpod Integration**: Designed for seamless use with Riverpod, leveraging
  `FamilyStreamNotifier` for state management and reactivity.
- **Query Customization**:
  - `queryCustomizer` in `FeedStreamNotifierSettings` allows defining a base set
    of filters for a feed.
- **Search**: The `search(String terms)` method on the notifier triggers a new
  fetch based on the search terms against the configured `searchColumn`. Count
  tracking is reset when search terms change.
- **Reactivity**: Feeds automatically update if the underlying
  `FeedStreamNotifierSettings` change (when the provider for settings is
  re-evaluated) or when methods like `search`, `refreshFeed`, or
  `fetchMoreItems` are called.
- **Stable `selectArgs` and `fromJsonFactory`**: These should ideally be static
  or top-level constants/functions to ensure stability for the
  `FeedStreamNotifierSettings`.
- **Disposal**: The notifier handles its own disposal and stops processing if
  the widget is unmounted, preventing errors.
- **Error Handling**: The `AsyncValue` provided by Riverpod
  (`asyncValue.when(...)`) should be used to handle loading and error states.

## Count Tracking Best Practices

1. **Use Count Information**: Display the total count to users when available
   for better UX
2. **Conditional Load More**: Only show "Load More" buttons when `hasMoreItems`
   is true
3. **Progress Indicators**: Use count information to show loading progress
4. **Search Results**: Display search result counts to help users understand the
   scope of results
5. **Performance**: The system prevents unnecessary API calls, but you should
   still debounce search input for the best user experience
