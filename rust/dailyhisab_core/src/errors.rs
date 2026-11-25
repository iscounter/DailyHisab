use thiserror::Error;

#[derive(Debug, Error, PartialEq, Eq, Clone)]
pub enum CoreError {
    #[error("invalid amount")]
    InvalidAmount,

    #[error("invalid input")]
    InvalidInput,

    #[error("invalid transfer")]
    InvalidTransfer,
}
