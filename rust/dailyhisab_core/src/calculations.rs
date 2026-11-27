use crate::CoreError;

pub fn sum_minor_units(values: &[i64]) -> i64 {
    values.iter().copied().sum()
}

pub fn format_bdt_minor(amount_minor: i64) -> String {
    let negative = amount_minor < 0;
    let abs = amount_minor.unsigned_abs();
    let major = abs / 100;
    let minor = abs % 100;
    let sign = if negative { "-" } else { "" };
    format!("{}৳{}.{}", sign, major, format!("{:02}", minor))
}

pub fn validate_minor_amount(amount_minor: i64) -> Result<(), CoreError> {
    if amount_minor <= 0 {
        return Err(CoreError::InvalidAmount);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sum_works() {
        assert_eq!(sum_minor_units(&[100, 250, -50]), 300);
    }

    #[test]
    fn format_works() {
        assert_eq!(format_bdt_minor(1050), "৳10.50");
        assert_eq!(format_bdt_minor(10050), "৳100.50");
    }

    #[test]
    fn validate_rejects_non_positive() {
        assert!(validate_minor_amount(0).is_err());
        assert!(validate_minor_amount(-1).is_err());
        assert!(validate_minor_amount(1).is_ok());
    }
}
