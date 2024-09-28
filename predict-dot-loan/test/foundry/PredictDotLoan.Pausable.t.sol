// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_Pausable_Test is PredictDotLoan_Test {
    event Paused(address account);
    event Unpaused(address account);

    function test_togglePaused() public asPrankedUser(owner) {
        expectEmitCheckAll();
        emit Paused(owner);

        predictDotLoan.togglePaused();
        assertTrue(predictDotLoan.paused());

        expectEmitCheckAll();
        emit Unpaused(owner);

        predictDotLoan.togglePaused();
        assertFalse(predictDotLoan.paused());
    }

    function test_togglePaused_RevertIf_AccessControlUnauthorizedAccount() public asPrankedUser(borrower) {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, borrower, bytes32(0))
        );
        predictDotLoan.togglePaused();
    }
}
