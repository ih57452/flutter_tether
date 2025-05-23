import 'package:example/database/supabase_select_builders.dart';

final imageSelect = ImagesSelectBuilder().select();
final genreSelect = GenresSelectBuilder().select();
final authorSelect = AuthorsSelectBuilder().select();
final bookGenreSelect = BookGenresSelectBuilder().select().withGenre(
  genreSelect,
);
final bookSelect = BooksSelectBuilder()
    .select()
    .withAuthor(authorSelect)
    .withBookGenres(bookGenreSelect)
    .withCoverImage(imageSelect)
    .withBannerImage(imageSelect);
final bookstoreBookSelect = BookstoreBooksSelectBuilder().select().withBook(
  bookSelect,
);

final bookstoreSelect = BookstoresSelectBuilder().select().withBookstoreBooks(
  bookstoreBookSelect,
);
