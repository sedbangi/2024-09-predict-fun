// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * 0. No error
 */

/**
 * @dev The proposal expected to be valid.
 */
uint256 constant PROPOSAL_EXPECTED_TO_BE_VALID = 0;

/**
 * 1. Expiration related codes
 */

/**
 * @dev The lending/borrowing proposal has expired.
 */
uint256 constant PROPOSAL_EXPIRED = 101;

/**
 * 2. Caller related codes
 */

/**
 * @dev The proposal's lender cannot be the proposal's borrower.
 */
uint256 constant LENDER_IS_BORROWER = 201;

/**
 * 3. Signature related codes
 */

/**
 * @dev The signature is invalid for the given signer and data hash.
 */
uint256 constant INVALID_SIGNATURE = 301;

/**
 * 4. Fulfillment related codes
 */

/**
 * @dev The fulfill amount was too low.
 */
uint256 constant FULFILL_AMOUNT_TOO_LOW = 401;

/**
 * @dev The fulfill amount was too high.
 */
uint256 constant FULFILL_AMOUNT_TOO_HIGH = 402;

/**
 * 5. Salt related codes
 */

/**
 * @dev The proposal was cancelled.
 */
uint256 constant PROPOSAL_CANCELLED = 501;

/**
 * @dev The salt was used by another proposal.
 */
uint256 constant SALT_ALREADY_USED = 511;

/**
 * 6. Nonce related codes
 */

/**
 * @dev The nonce is not current.
 */
uint256 constant NONCE_IS_NOT_CURRENT = 601;

/**
 * 7. Collateral related codes
 */

/**
 * @dev The collateralization ratio is below 100%.
 */
uint256 constant COLLATERALIZATION_RATIO_BELOW_100 = 701;

/**
 * 8. Interest rate related codes
 */

/**
 * @dev The interest rate is below the minimum interest rate.
 */
uint256 constant INTEREST_RATE_TOO_LOW = 801;

/**
 * @dev The interest rate is above the maximum interest rate.
 */
uint256 constant INTEREST_RATE_TOO_HIGH = 802;

/**
 * 9. Tradeability related codes
 */

/**
 * @dev The position is not tradeable.
 */
uint256 constant POSITION_IS_NOT_TRADEABLE = 901;

/**
 * 10. Question state related codes
 */

/**
 * @dev The question is resolved.
 */
uint256 constant QUESTION_RESOLVED = 1_001;

/**
 * @dev The market is resolved.
 */
uint256 constant MARKET_RESOLVED = 1_002;

/**
 * @dev The question state is abnormal.
 */
uint256 constant QUESTION_STATE_ABNORMAL = 1_011;
