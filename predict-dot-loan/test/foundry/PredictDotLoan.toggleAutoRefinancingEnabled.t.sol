// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_ToggleAutoRefinancingEnabled_Test is PredictDotLoan_Test {
    function test_toggleAutoRefinancingEnabled() public asPrankedUser(borrower) {
        assertEq(predictDotLoan.autoRefinancingEnabled(borrower), 0);

        expectEmitCheckAll();
        emit AutoRefinancingEnabledToggled(borrower, 1);

        predictDotLoan.toggleAutoRefinancingEnabled();
        assertEq(predictDotLoan.autoRefinancingEnabled(borrower), 1);

        expectEmitCheckAll();
        emit AutoRefinancingEnabledToggled(borrower, 0);

        predictDotLoan.toggleAutoRefinancingEnabled();
        assertEq(predictDotLoan.autoRefinancingEnabled(borrower), 0);
    }
}
