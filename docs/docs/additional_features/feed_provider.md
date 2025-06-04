---
sidebar_position: 1
---

# Feed Management System

Tether includes an optional, powerful Feed Management System designed to
simplify the creation and management of paginated content feeds within your
Flutter application. This system leverages a Tether-managed local SQLite table
(`feed_item_references`) to store the order and references of feed items,
combined with a Riverpod `StreamNotifier` for reactive UI updates.

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
     - Fetching initial data.
     - Fetching subsequent pages (pagination).
     - Applying search terms (if configured).
     - Applying dynamic filters.
     - Storing item references and their order in the local
       `feed_item_references` table.
     - Streaming the ordered list of `TModel` items to the UI.

The system works by first fetching item IDs (and potentially other minimal data)
from your Supabase backend based on the configuration. These references are
stored locally. The `FeedStreamNotifier` then watches this local table and
fetches the full model data (using the `selectArgs`) for the referenced items,
providing a reactive stream of `List<TModel>`.

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

### 2. Use in a Widget

Consume the provider in your widget to display the feed and handle interactions.

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

  // ... dispose, _scrollListener ...

  Future<void> _fetchMore() async {
    if (_isFetchingMore) return;
    setState(() => _isFetchingMore = true);

    final settings = ref.read(bookFeedProvider); // Get current settings
    final notifier = ref.read(booksFeedProvider(settings).notifier);
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
    final booksAsyncValue = ref.watch(booksFeedProvider(settings)); // Watch the feed data, rebuilds feed on settings change

    // ... UI rendering using booksAsyncValue, genre selection chips ...
    // ListView.builder uses _scrollController
  }
}
```

## Setting up a Search Feed

A search feed allows users to input search terms, typically for full-text
search. This assume that full-text search is already set up in your Supabase
database. When set up properly full-text search is fast and can provide near
real-time results.

### 1. Define `FeedStreamNotifierSettings`

Configure settings specifically for search, including the `searchColumn`.

```dart
final bookSearchSettingsProvider = Provider<FeedStreamNotifierSettings<BookModel>>((ref) {
  final bookClientManager = ref.watch(booksManagerProvider);
  return FeedStreamNotifierSettings<BookModel>(
    feedKey: 'books_search_feed', // Unique key for this search feed
    searchColumn: BooksColumn.tsvector, // The tsvector column for FTS, you manually have to pass this in.
    clientManager: bookClientManager,
    selectArgs: bookSelect, // Your predefined SupabaseSelectBuilderBase instance
    fromJsonFactory: BookModel.fromJson,
    pageSize: 20,
    // queryCustomizer can also be used here for base filters on the search, if needed
  );
});
```

### 2. Use in a Widget

Consume the provider and use the notifier's `search()` method.

```dart
class SearchFeedTab extends ConsumerStatefulWidget {
  // ...
}

class _SearchFeedTabState extends ConsumerState<SearchFeedTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // ... _searchTerm, _isFetchingMore, initState, dispose, _scrollListener ...

  Future<void> _fetchMore() async {
    if (_isFetchingMore) return;
    setState(() => _isFetchingMore = true);

    final settings = ref.read(bookSearchSettingsProvider); // Get current settings
    final notifier = ref.read(booksFeedProvider(settings).notifier);
    await notifier.fetchMoreItems();

    if (mounted) {
      setState(() => _isFetchingMore = false);
    }
  }

  void _performSearch() {
    final searchTerm = _searchController.text;
    final settings = ref.read(bookSearchSettingsProvider); // Get current settings
    final notifier = ref.read(booksFeedProvider(settings).notifier);
    notifier.search(searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(bookSearchSettingsProvider); // Watch for settings changes (if any)
    final asyncValue = ref.watch(booksFeedProvider(settings)); // Watch the feed data

    // ... UI rendering with TextField for search input, ListView for results ...
    // ListView.builder uses _scrollController
  }
}
```

## Key Features & Usage Notes

- **Local Caching of Feed Structure**: The `feed_item_references` table stores
  the `feed_key`, the source table of the item, the item's ID, and its display
  order. This allows for persistent, ordered feeds. The actual item data is
  fetched based on these references and also benefits from the `ClientManager`'s
  local caching of individual models. Note, this is fully managed in the
  background and you don't have to interact with it.
  - **`feedKey` Importance**: Ensure each distinct feed in your application uses
    a unique `feedKey`. This prevents data from different feeds from mixing in
    the local `feed_item_references` table.
- **Riverpod Integration**: Designed for seamless use with Riverpod, leveraging
  `FamilyStreamNotifier` for state management and reactivity.
- **Pagination**: The `fetchMoreItems()` method on the notifier handles loading
  subsequent pages.
- **Query Customization**:
  - `queryCustomizer` in `FeedStreamNotifierSettings` allows defining a base set
    of filters for a feed.
- **Search**: The `search(String terms)` method on the notifier triggers a new
  fetch based on the search terms against the configured `searchColumn`.
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
