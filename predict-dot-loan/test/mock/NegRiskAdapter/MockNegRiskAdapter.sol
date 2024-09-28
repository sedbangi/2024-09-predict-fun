// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {Helpers} from "./Helpers.sol";
import {Auth} from "../CTFExchange/Auth.sol";
import {IConditionalTokens} from "../interfaces/IConditionalTokens.sol";
import {CTHelpers} from "../ConditionalTokens/CTHelpers.sol";
import {WrappedCollateral} from "../WrappedCollateral.sol";

import {NegRiskIdLib} from "../../../contracts/libraries/NegRiskIdLib.sol";

contract MockNegRiskAdapter is ERC1155Holder, Auth {
    using SafeERC20 for ERC20;

    mapping(bytes32 marketId => bool) public determined;

    IConditionalTokens public immutable ctf;
    ERC20 public immutable col;
    WrappedCollateral public immutable wcol;

    error NotApprovedForAll();
    error UnexpectedCollateralToken();

    constructor(address _ctf, address _collateral) {
        ctf = IConditionalTokens(_ctf);
        col = ERC20(_collateral);
        wcol = new WrappedCollateral(_collateral, 18);

        // approve the ctf to transfer wcol on our behalf
        wcol.approve(_ctf, type(uint256).max);
        // approve wcol to transfer collateral on our behalf
        col.approve(address(wcol), type(uint256).max);
    }

    function setDetermined(bytes32 questionId, bool value) external {
        bytes32 marketId = NegRiskIdLib.getMarketId(questionId);
        determined[marketId] = value;
    }

    function getDetermined(bytes32 marketId) external view returns (bool) {
        return determined[marketId];
    }

    function prepareCondition(bytes32 questionId) external {
        bytes32 conditionId = CTHelpers.getConditionId(address(this), questionId, 2);
        if (ctf.getOutcomeSlotCount(conditionId) == 0) {
            ctf.prepareCondition(questionId, 2);
        }
    }

    /// @notice Splits collateral to a complete set of conditional tokens for a single question
    /// @notice This function signature is the same as the CTF's splitPosition
    /// @param _collateralToken - the collateral token, must be the same as the adapter's collateral token
    /// @param _conditionId - the conditionId for the question
    /// @param _amount - the amount of collateral to split
    function splitPosition(
        address _collateralToken,
        bytes32,
        bytes32 _conditionId,
        uint256[] calldata,
        uint256 _amount
    ) external {
        if (_collateralToken != address(col)) revert UnexpectedCollateralToken();
        splitPosition(_conditionId, _amount);
    }

    /// @notice Splits collateral to a complete set of conditional tokens for a single question
    /// @param _conditionId - the conditionId for the question
    /// @param _amount      - the amount of collateral to split
    function splitPosition(bytes32 _conditionId, uint256 _amount) public {
        col.safeTransferFrom(msg.sender, address(this), _amount);
        wcol.wrap(address(this), _amount);
        ctf.splitPosition(address(wcol), bytes32(0), _conditionId, Helpers.partition(), _amount);
        ctf.safeBatchTransferFrom(
            address(this),
            msg.sender,
            Helpers.positionIds(address(wcol), _conditionId),
            Helpers.values(2, _amount),
            ""
        );
    }

    /// @notice Proxies ERC1155 safeTransferFrom to the CTF
    /// @notice Can only be called by an admin
    /// @notice Requires this contract to be approved for all
    /// @notice Requires the sender to be approved for all
    /// @param _from  - the owner of the tokens
    /// @param _to    - the recipient of the tokens
    /// @param _id    - the positionId
    /// @param _value - the amount of tokens to transfer
    /// @param _data  - the data to pass to the recipient
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external onlyAdmin {
        if (!ctf.isApprovedForAll(_from, msg.sender)) {
            revert NotApprovedForAll();
        }

        return ctf.safeTransferFrom(_from, _to, _id, _value, _data);
    }

    /// @notice Returns the conditionId for a given questionId
    /// @param _questionId  - the questionId
    /// @return conditionId - the corresponding conditionId
    function getConditionId(bytes32 _questionId) public view returns (bytes32) {
        return
            CTHelpers.getConditionId(
                address(this), // oracle
                _questionId,
                2 // outcomeCount
            );
    }

    /// @notice Returns the positionId for a given questionId and outcome
    /// @param _questionId  - the questionId
    /// @param _outcome     - the boolean outcome
    /// @return positionId  - the corresponding positionId
    function getPositionId(bytes32 _questionId, bool _outcome) public view returns (uint256) {
        bytes32 collectionId = CTHelpers.getCollectionId(
            bytes32(0),
            getConditionId(_questionId),
            _outcome ? 1 : 2 // 1 (0b01) is yes, 2 (0b10) is no
        );

        uint256 positionId = CTHelpers.getPositionId(IERC20(address(wcol)), collectionId);
        return positionId;
    }
}
