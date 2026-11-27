//! Pure aggregation over transactions. All amounts are integer minor units.
//!
//! No floating point is used anywhere. Arithmetic saturates instead of
//! overflowing, so callers never observe a wrapped balance.

/// Transaction kind.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TxnKind {
    Income,
    Expense,
    Transfer,
}

/// A minimal transaction record for aggregation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Txn {
    pub kind: TxnKind,
    pub amount_minor: i64,
    pub from_account: Option<u32>,
    pub to_account: Option<u32>,
}

impl Txn {
    pub fn income(amount_minor: i64, to_account: u32) -> Self {
        Self {
            kind: TxnKind::Income,
            amount_minor,
            from_account: None,
            to_account: Some(to_account),
        }
    }

    pub fn expense(amount_minor: i64, from_account: u32) -> Self {
        Self {
            kind: TxnKind::Expense,
            amount_minor,
            from_account: Some(from_account),
            to_account: None,
        }
    }

    pub fn transfer(amount_minor: i64, from_account: u32, to_account: u32) -> Self {
        Self {
            kind: TxnKind::Transfer,
            amount_minor,
            from_account: Some(from_account),
            to_account: Some(to_account),
        }
    }
}

/// Sum of all income amounts.
pub fn total_income_minor(txns: &[Txn]) -> i64 {
    txns.iter()
        .filter(|t| t.kind == TxnKind::Income)
        .fold(0, |acc, t| acc.saturating_add(t.amount_minor))
}

/// Sum of all expense amounts.
pub fn total_expense_minor(txns: &[Txn]) -> i64 {
    txns.iter()
        .filter(|t| t.kind == TxnKind::Expense)
        .fold(0, |acc, t| acc.saturating_add(t.amount_minor))
}

/// Derived balance for one account: opening + income in - expense out
/// + transfers in - transfers out. Transfers never change the combined total.
pub fn account_balance_minor(txns: &[Txn], account: u32, opening_minor: i64) -> i64 {
    let mut balance = opening_minor;
    for t in txns {
        match t.kind {
            TxnKind::Income => {
                if t.to_account == Some(account) {
                    balance = balance.saturating_add(t.amount_minor);
                }
            }
            TxnKind::Expense => {
                if t.from_account == Some(account) {
                    balance = balance.saturating_sub(t.amount_minor);
                }
            }
            TxnKind::Transfer => {
                if t.from_account == Some(account) {
                    balance = balance.saturating_sub(t.amount_minor);
                }
                if t.to_account == Some(account) {
                    balance = balance.saturating_add(t.amount_minor);
                }
            }
        }
    }
    balance
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn income_and_expense_totals() {
        let txns = [
            Txn::income(25_000, 1),
            Txn::expense(12_550, 1),
            Txn::income(5_000, 1),
        ];
        assert_eq!(total_income_minor(&txns), 30_000);
        assert_eq!(total_expense_minor(&txns), 12_550);
    }

    #[test]
    fn transfer_preserves_combined_balance() {
        let txns = [Txn::transfer(10_000, 1, 2)];
        let a = account_balance_minor(&txns, 1, 0);
        let b = account_balance_minor(&txns, 2, 0);
        assert_eq!(a, -10_000);
        assert_eq!(b, 10_000);
        assert_eq!(a + b, 0);
    }

    #[test]
    fn opening_balance_is_included() {
        let txns = [Txn::expense(5_000, 1)];
        assert_eq!(account_balance_minor(&txns, 1, 100_000), 95_000);
    }
}