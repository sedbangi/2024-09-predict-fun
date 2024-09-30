// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_MinimumOrderFeeRate_Test is PredictDotLoan_Test {
    function test_updateMinimumOrderFeeRate() public asPrankedUser(owner) {
        expectEmitCheckAll();
        emit MinimumOrderFeeRateUpdated(100);

        predictDotLoan.updateMinimumOrderFeeRate(100);

        bytes32 slot12 = vm.load(address(predictDotLoan), bytes32(uint256(12)));
        assertEq(uint16(uint256(slot12) >> 168), 100);
    }

    function test_updateMinimumOrderFeeRate_RevertIf_UnauthorizedAccount() public asPrankedUser(borrower) {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, borrower, bytes32(0))
        );
        predictDotLoan.updateMinimumOrderFeeRate(100);
    }
}
