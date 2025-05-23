// GENERATED CODE - DO NOT MODIFY BY HAND
// Core Migration: Feed Item References
// Migration version: 0000
// Generated on 2025-05-22T16:52:53.913666

const List<String> migrationSqlStatementsV0000_core_feed = [
  '''-- Core Feed Item References Table (Version 0000)''',
  '''-- Generated on 2025-05-22T16:52:53.913666''',
  r'''
CREATE TABLE IF NOT EXISTS feed_item_references (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    feed_key TEXT NOT NULL,
    item_source_table TEXT NOT NULL,
    item_source_id TEXT NOT NULL,
    display_order INTEGER NOT NULL,
    CONSTRAINT uq_feed_item_uniqueness UNIQUE (feed_key, item_source_table, item_source_id),
    CONSTRAINT uq_feed_item_order UNIQUE (feed_key, display_order)
);
''',
  r'''
CREATE INDEX IF NOT EXISTS idx_feed_items_by_feed_key_and_order ON feed_item_references (feed_key, display_order);
''',
  r'''
CREATE TABLE IF NOT EXISTS user_preferences (
    preference_key TEXT PRIMARY KEY NOT NULL,
    preference_value TEXT, -- Stored as JSON string
    value_type TEXT NOT NULL CHECK(value_type IN ('TEXT', 'INTEGER', 'REAL', 'BOOLEAN', 'TEXT_ARRAY', 'JSON_OBJECT', 'JSON_ARRAY')) -- Type hint for deserialization
);
''',
  r'''
CREATE INDEX IF NOT EXISTS idx_user_preferences_key ON user_preferences (preference_key);
''',
];
