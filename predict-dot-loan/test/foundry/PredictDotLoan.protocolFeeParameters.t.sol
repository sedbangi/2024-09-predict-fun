// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {IPredictDotLoan} from "../../contracts/interfaces/IPredictDotLoan.sol";

import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_ProtocolFeeParameters_Test is PredictDotLoan_Test {
    function test_updateProtocolFeeRecipient() public asPrankedUser(owner) {
        expectEmitCheckAll();
        emit ProtocolFeeRecipientUpdated(address(0x1));

        predictDotLoan.updateProtocolFeeRecipient(address(0x1));

        bytes32 slot12 = vm.load(address(predictDotLoan), bytes32(uint256(12)));
        assertEq(address(uint160(uint256(slot12))), address(0x1));
    }

    function test_updateProtocolFeeRecipient_RevertIf_ZeroAddress() public asPrankedUser(owner) {
        predictDotLoan.updateProtocolFeeRecipient(address(0x1));

        vm.expectRevert(IPredictDotLoan.ZeroAddress.selector);
        predictDotLoan.updateProtocolFeeRecipient(address(0));
    }

    function test_updateProtocolFeeRecipient_RevertIf_AccessControlUnauthorizedAccount()
        public
        asPrankedUser(borrower)
    {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, borrower, bytes32(0))
        );
        predictDotLoan.updateProtocolFeeRecipient(address(0x1));
    }

    function test_updateProtocolFeeBasisPoints() public asPrankedUser(owner) {
        expectEmitCheckAll();
        emit ProtocolFeeBasisPointsUpdated(200);

        predictDotLoan.updateProtocolFeeBasisPoints(200);
        assertEq(_getProtocolFeeBasisPoints(), 200);

        bytes32 slot12 = vm.load(address(predictDotLoan), bytes32(uint256(12)));
        assertEq(uint8(uint256(slot12) >> 160), 200);
    }

    function test_updateProtocolFeeBasisPoints_RevertIf_ProtocolFeeBasisPointsTooHigh() public asPrankedUser(owner) {
        vm.expectRevert(IPredictDotLoan.ProtocolFeeBasisPointsTooHigh.selector);
        predictDotLoan.updateProtocolFeeBasisPoints(201);
    }

    function test_updateProtocolFeeBasisPoints_RevertIf_AccessControlUnauthorizedAccount()
        public
        asPrankedUser(borrower)
    {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, borrower, bytes32(0))
        );
        predictDotLoan.updateProtocolFeeBasisPoints(200);
    }
}
