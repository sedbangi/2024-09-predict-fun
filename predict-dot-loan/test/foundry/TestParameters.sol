// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract TestParameters {
    uint256 internal constant ONE = 1 ether;
    uint256 internal constant TEN_PERCENT_APY = 3_020_262_040;
    uint256 internal constant TEN_THOUSAND_APY = 146_247_483_013;

    uint256 internal constant AUCTION_DURATION = 1 days;
    uint256 internal constant LOAN_DURATION = 1 days;

    uint256 internal constant COLLATERAL_AMOUNT = 1_000 ether;
    uint256 internal constant LOAN_AMOUNT = 700 ether;
    uint256 internal constant EXPECTED_DEBT_AFTER_12_HOURS = 700.0913386825349551 ether;

    uint256 internal constant INTEREST_RATE_PER_SECOND = ONE + TEN_PERCENT_APY;
}
