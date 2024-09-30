// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import {ICTFExchange, Order, Side} from "../../../contracts/interfaces/ICTFExchange.sol";

import {Auth} from "./Auth.sol";
import {CalculatorHelper} from "./CalculatorHelper.sol";

contract MockCTFExchange is ICTFExchange, Auth {
    address private immutable ctf;
    address private immutable collateral;

    bool private simulateFailedOrderWithoutRevert = false;

    mapping(uint256 => OutcomeToken) public registry;

    event OrderFilled(
        bytes32 indexed orderHash,
        address indexed maker,
        address indexed taker,
        uint256 makerAssetId,
        uint256 takerAssetId,
        uint256 makerAmountFilled,
        uint256 takerAmountFilled,
        uint256 fee
    );

    error InvalidTokenId();
    error AlreadyRegistered();

    constructor(address _conditionalTokens, address _collateral) {
        ctf = _conditionalTokens;
        collateral = _collateral;
    }

    function setSimulateFailedOrderWithoutRevert(bool simulate) external {
        simulateFailedOrderWithoutRevert = simulate;
    }

    function fillOrder(Order memory order, uint256 fillAmount) external onlyOperator {
        _fillOrder(order, fillAmount, msg.sender);
    }

    function registerToken(uint256 token0, uint256 token1, bytes32 conditionId) external {
        if (token0 == token1 || (token0 == 0 || token1 == 0)) revert InvalidTokenId();
        if (registry[token0].complement != 0 || registry[token1].complement != 0) revert AlreadyRegistered();

        registry[token0] = OutcomeToken({complement: token1, conditionId: conditionId});
        registry[token1] = OutcomeToken({complement: token0, conditionId: conditionId});

        emit TokenRegistered(token0, token1, conditionId);
        emit TokenRegistered(token1, token0, conditionId);
    }

    function deregisterToken(uint256 token0, uint256 token1) external {
        registry[token0] = OutcomeToken({complement: 0, conditionId: bytes32(0)});
        registry[token1] = OutcomeToken({complement: 0, conditionId: bytes32(0)});
    }

    function getCtf() public view returns (address) {
        return ctf;
    }

    function getCollateral() public view returns (address) {
        return collateral;
    }

    /// @notice Fills an order against the caller
    /// @param order        - The order to be filled
    /// @param fillAmount   - The amount to be filled, always in terms of the maker amount
    /// @param to           - The address to receive assets from filling the order
    function _fillOrder(Order memory order, uint256 fillAmount, address to) internal {
        uint256 making = fillAmount;
        (uint256 taking, bytes32 orderHash) = _performOrderChecks(order, making);

        uint256 fee = CalculatorHelper.calculateFee(
            order.feeRateBps,
            order.side == Side.BUY ? taking : making,
            order.makerAmount,
            order.takerAmount,
            order.side
        );

        (uint256 makerAssetId, uint256 takerAssetId) = _deriveAssetIds(order);

        // Transfer order proceeds minus fees from msg.sender to order maker
        _transfer(msg.sender, order.maker, takerAssetId, taking - fee);

        if (!simulateFailedOrderWithoutRevert) {
            // Transfer makingAmount from order maker to `to`
            _transfer(order.maker, to, makerAssetId, making);
        }

        emit OrderFilled(orderHash, order.maker, msg.sender, makerAssetId, takerAssetId, making, taking, fee);
    }

    function _deriveAssetIds(Order memory order) internal pure returns (uint256 makerAssetId, uint256 takerAssetId) {
        if (order.side == Side.BUY) return (0, order.tokenId);
        return (order.tokenId, 0);
    }

    function _transfer(address token, address from, address to, uint256 id, uint256 amount) internal {
        if (amount > 0) {
            if (id == 0) {
                from == address(this) ? ERC20(token).transfer(to, amount) : ERC20(token).transferFrom(from, to, amount);
            } else {
                return ERC1155(token).safeTransferFrom(from, to, id, amount, "");
            }
        }
    }

    function _transfer(address from, address to, uint256 id, uint256 value) internal {
        if (id == 0) return _transferCollateral(from, to, value);
        return _transferCTF(from, to, id, value);
    }

    function _transferCollateral(address from, address to, uint256 value) internal {
        address token = getCollateral();
        if (from == address(this)) ERC20(token).transfer(to, value);
        else ERC20(token).transferFrom(from, to, value);
    }

    function _transferCTF(address from, address to, uint256 id, uint256 value) internal {
        ERC1155(getCtf()).safeTransferFrom(from, to, id, value, "");
    }

    function _performOrderChecks(
        Order memory order,
        uint256 making
    ) internal pure returns (uint256 takingAmount, bytes32 orderHash) {
        orderHash = bytes32(0);
        takingAmount = CalculatorHelper.calculateTakingAmount(making, order.makerAmount, order.takerAmount);
    }
}
