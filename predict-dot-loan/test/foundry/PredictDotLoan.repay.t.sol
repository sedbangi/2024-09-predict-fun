// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IPredictDotLoan} from "../../contracts/interfaces/IPredictDotLoan.sol";
import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_Repay_Test is PredictDotLoan_Test {
    function test_calculateDebt_TimeElapsedIsZero() public {
        testFuzz_acceptLoanOffer(0);

        uint256 debt = predictDotLoan.calculateDebt(1);
        assertEq(debt, 700 ether);
    }

    function test_repay_RevertIf_UnauthorizedCaller() public {
        testFuzz_acceptLoanOffer(0);

        vm.expectRevert(IPredictDotLoan.UnauthorizedCaller.selector);
        predictDotLoan.repay(1);
    }

    function test_repay_RevertIf_InvalidLoanStatus() public {
        test_repay_LoanHasNotBeenCalled();

        vm.expectRevert(IPredictDotLoan.InvalidLoanStatus.selector);
        vm.prank(borrower);
        predictDotLoan.repay(1);
    }
}
