import 'package:sqlite_async/sqlite3_common.dart';

/// Abstract base class for data models representing database table rows.
///
/// Concrete implementations (typically generated) should:
/// 1. Define final fields corresponding to table columns.
/// 2. Provide a constructor to initialize all fields.
/// 3. Implement the `toJson` method for serialization to JSON (e.g., for Supabase).
/// 4. Implement the `toSqlite` method for serialization to a map suitable for SQLite.
/// 5. Implement `copyWith` for creating modified copies.
/// 6. Override `toString`, `operator ==`, and `hashCode` for debugging and equality checks.
/// 7. **By convention, provide `fromJson` and `fromSqlite` factory constructors**
///    for deserialization from different data sources. These cannot be enforced
///    by the abstract class itself but are essential for using the models effectively.
abstract class TetherModel<T> {
  final Map<String, dynamic> data;

  TetherModel(this.data);

  /// The primary identifier for the model instance, typically mapping to a primary key.
  /// Type can be String, int, etc., depending on the specific table.
  dynamic get localId => data['id'];

  /// Converts the model instance into a JSON map (Map<String, dynamic>).
  ///
  /// This map typically uses snake_case keys corresponding to database column names
  /// and is suitable for sending data to APIs (like Supabase).
  /// DateTime objects should usually be converted to ISO 8601 strings.
  Map<String, dynamic> toJson();

  /// Converts the model instance into a map (Map<String, dynamic>) suitable for
  /// inserting or updating in an SQLite database.
  ///
  /// This map typically uses snake_case keys corresponding to database column names.
  /// DateTime objects might be stored as ISO 8601 strings or Unix timestamps (integers),
  /// depending on the database schema and chosen serialization strategy.
  /// Boolean values are typically stored as integers (0 or 1).
  Map<String, dynamic> toSqlite(); // Added abstract method

  /// Creates a copy of this model instance, allowing specific fields to be
  /// overridden with new values.
  ///
  /// Implementations should return an instance of the concrete model type (`T`).
  /// Parameters should be optional and named, corresponding to the model's fields.
  T copyWith(/* Specific named, optional parameters defined in subclass */);

  /// Returns a string representation of the model instance, typically including
  /// the class name and the values of its fields. Useful for debugging.
  @override
  String toString();

  factory TetherModel.fromJson(Map<String, dynamic> json) {
    // Filter the JSON to include only columns defined in the schema

    // Return a new instance of TetherModel with the filtered data
    return _GenericTetherModel(json) as TetherModel<T>;
  }

  factory TetherModel.fromSqlite(Row sqliteData) {
    // Filter the SQLite data to include only columns defined in the schema

    // Return a new instance of TetherModel with the filtered data
    return _GenericTetherModel(sqliteData) as TetherModel<T>;
  }
}

class _GenericTetherModel extends TetherModel<dynamic> {
  _GenericTetherModel(super.data);

  @override
  dynamic get _id => data['id']; // Assuming 'id' is the primary key column

  @override
  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(data);
  }

  @override
  Map<String, dynamic> toSqlite() {
    // Convert the data to a format suitable for SQLite (e.g., handle DateTime, booleans)
    return Map<String, dynamic>.from(data);
  }

  @override
  _GenericTetherModel copyWith({Map<String, dynamic>? newData}) {
    return _GenericTetherModel({...data, ...?newData});
  }
}
