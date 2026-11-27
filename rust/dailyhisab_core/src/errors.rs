use thiserror::Error;

#[derive(Debug, Error)]
pub enum CoreError {
    #[error("invalid amount")]
    InvalidAmount,

    #[error("invalid input")]
    InvalidInput,

    #[error("invalid transfer")]
    InvalidTransfer,
}