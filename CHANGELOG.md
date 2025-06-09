## 1.0.0

- Initial version.

## 1.1.0

- Changed the `TetherClientReturn` class to include a `data` field for better
  handling of results.
- Added `count` field to `TetherClientReturn` for total record count in queries.
- Updated all manager operations to return `TetherClientReturn<TModel>` instead
  of just `List<TModel>`.
- Fixed error in Model generation where M2M getters were not generated
  correctly.
