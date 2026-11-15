# DailyHisab Architecture

- Flutter (UI) + Riverpod + GoRouter
- Drift/SQLite for offline storage (to be implemented)
- Rust `dailyhisab_core` for money math/report helpers (FFI integration later)
- Money: integer minor units (BDT poisha), no floating point.
