//! Domain validation shared across native clients.
//! All amounts are integer minor units.

use crate::aggregation::TxnKind;
use crate::errors::CoreError;

/// Validate a transfer: positive amount, both accounts present and different.
pub fn validate_transfer(
    from_account: Option<u32>,
    to_account: Option<u32>,
    amount_minor: i64,
) -> Result<(), CoreError> {
    if amount_minor <= 0 {
        return Err(CoreError::InvalidAmount);
    }
    match (from_account, to_account) {
        (Some(from), Some(to)) if from != to => Ok(()),
        _ => Err(CoreError::InvalidTransfer),
    }
}

/// Validate a transaction of any kind against the accounting invariants.
pub fn validate_tx(
    kind: TxnKind,
    amount_minor: i64,
    from_account: Option<u32>,
    to_account: Option<u32>,
) -> Result<(), CoreError> {
    if amount_minor <= 0 {
        return Err(CoreError::InvalidAmount);
    }
    match kind {
        TxnKind::Income => match to_account {
            Some(_) => Ok(()),
            None => Err(CoreError::InvalidInput),
        },
        TxnKind::Expense => match from_account {
            Some(_) => Ok(()),
            None => Err(CoreError::InvalidInput),
        },
        TxnKind::Transfer => validate_transfer(from_account, to_account, amount_minor),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_non_positive_amount() {
        assert_eq!(
            validate_tx(TxnKind::Expense, 0, Some(1), None),
            Err(CoreError::InvalidAmount)
        );
    }

    #[test]
    fn income_requires_destination() {
        assert_eq!(
            validate_tx(TxnKind::Income, 100, None, None),
            Err(CoreError::InvalidInput)
        );
        assert_eq!(validate_tx(TxnKind::Income, 100, None, Some(1)), Ok(()));
    }

    #[test]
    fn expense_requires_source() {
        assert_eq!(
            validate_tx(TxnKind::Expense, 100, None, Some(1)),
            Err(CoreError::InvalidInput)
        );
        assert_eq!(validate_tx(TxnKind::Expense, 100, Some(1), None), Ok(()));
    }

    #[test]
    fn transfer_requires_distinct_accounts() {
        assert_eq!(
            validate_tx(TxnKind::Transfer, 100, Some(1), Some(1)),
            Err(CoreError::InvalidTransfer)
        );
        assert_eq!(validate_tx(TxnKind::Transfer, 100, Some(1), Some(2)), Ok(()));
    }
}