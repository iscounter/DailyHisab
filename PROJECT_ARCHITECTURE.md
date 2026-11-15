# DailyHisab — Project Architecture (v1)

## Decisions
- Type: Personal finance (income/expense/savings)
- Currency: BDT (store as integer minor units, poisha)
- Data: offline-first (SQLite via Drift), cloud sync later

## Layers
- Flutter UI (Material 3)
- Dart app layer: Riverpod providers, GoRouter, usecases/services
- Data: Drift DB + repositories
- Rust: `dailyhisab_core` for deterministic money math and aggregation helpers (FFI later)

## Core tables (Drift)
- accounts
- categories (income/expense)
- transactions (amount_minor int, currency_code='BDT')
- budgets (monthly)
- savings_goals
- debts
- recurring_transactions
- app_settings

## Money
- All amounts: `int` minor units. `double` forbidden for money.
