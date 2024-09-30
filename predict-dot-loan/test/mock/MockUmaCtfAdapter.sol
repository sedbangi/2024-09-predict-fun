// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IConditionalTokens} from "./interfaces/IConditionalTokens.sol";

contract MockUmaCtfAdapter {
    enum PayoutStatus {
        HasPrice,
        Flagged,
        NotInitialized,
        Paused,
        PriceNotAvailable
    }

    address public immutable ctf;

    mapping(bytes32 questionId => PayoutStatus) payoutStatus;

    error Flagged();
    error NotInitialized();
    error Paused();
    error PriceNotAvailable();

    constructor(address _ctf) {
        ctf = _ctf;
    }

    /**
     * @dev This is a mock function that doesn't exist in the real UMA CTF Adapter
     */
    function prepareCondition(bytes memory data) external {
        bytes32 questionId = keccak256(data);
        IConditionalTokens(ctf).prepareCondition(questionId, 2);
    }

    function setPayoutStatus(bytes32 questionId, PayoutStatus status) external {
        payoutStatus[questionId] = status;
    }

    function getExpectedPayouts(bytes32 questionId) external view returns (uint256[] memory payouts) {
        if (payoutStatus[questionId] == PayoutStatus.HasPrice) {
            payouts = new uint256[](2);
            payouts[0] = 1 ether;
            payouts[1] = 0;
        } else if (payoutStatus[questionId] == PayoutStatus.Flagged) {
            revert Flagged();
        } else if (payoutStatus[questionId] == PayoutStatus.NotInitialized) {
            revert NotInitialized();
        } else if (payoutStatus[questionId] == PayoutStatus.Paused) {
            revert Paused();
        } else if (payoutStatus[questionId] == PayoutStatus.PriceNotAvailable) {
            revert PriceNotAvailable();
        }
    }
}
