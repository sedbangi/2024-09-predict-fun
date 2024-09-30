// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface INegRiskAdapter {
    function ctf() external view returns (address);
    function getDetermined(bytes32 _marketId) external view returns (bool);
    function getPositionId(bytes32 questionId, bool outcome) external view returns (uint256);
}
