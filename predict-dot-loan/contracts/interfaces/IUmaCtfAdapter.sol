// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IUmaCtfAdapter {
    function getExpectedPayouts(bytes32 questionId) external view returns (uint256[] memory);
}
