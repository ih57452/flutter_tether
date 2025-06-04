# Tether Libs

**Tether Libs** is the runtime library package for Flutter Tether, providing the
core functionality needed to build robust Flutter applications with Supabase
integration, local SQLite caching, and powerful data management capabilities.

[![Pub Version](https://img.shields.io/pub/v/tether_libs)](https://pub.dev/packages/tether_libs)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🎯 Purpose

This package contains the runtime components that power applications built with
the Tether code generator. It provides:

- **Client Managers** - High-level interfaces for data operations with automatic
  local caching
- **Real-time Synchronization** - Seamless Supabase real-time subscription
  management
- **Authentication Management** - Complete auth flow with profile handling
- **Background Services** - Persistent job queue for background processing
- **Utilities** - Helper classes for common operations

## 📦 Installation

```yaml
dependencies:
  tether_libs: ^1.0.0
  # Required peer dependencies
  supabase_flutter: ^2.9.0
  sqlite_async: ^0.11.5
  flutter_background_service: ^5.1.0  # Optional: for background services
```
