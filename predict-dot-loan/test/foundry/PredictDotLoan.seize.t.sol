// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IPredictDotLoan} from "../../contracts/interfaces/IPredictDotLoan.sol";
import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

import {MockUmaCtfAdapter} from "../mock/MockUmaCtfAdapter.sol";

contract PredictDotLoan_Seize_Test is PredictDotLoan_Test {
    function test_seize_AuctionNotOver_ButQuestionIsResolved() public {
        test_call();

        vm.warp(vm.getBlockTimestamp() + AUCTION_DURATION);

        mockUmaCtfAdapter.setPayoutStatus(questionId, MockUmaCtfAdapter.PayoutStatus.HasPrice);

        vm.prank(lender);
        predictDotLoan.seize(1);

        IPredictDotLoan.LoanStatus status = _getLoanStatus(1);
        assertEq(uint8(status), uint8(IPredictDotLoan.LoanStatus.Defaulted));

        assertEq(mockCTF.balanceOf(address(predictDotLoan), _getPositionId(true)), 0);
        assertEq(mockCTF.balanceOf(lender, _getPositionId(true)), COLLATERAL_AMOUNT);
    }

    function test_seize_RevertIf_AuctionNotOver() public {
        test_call();

        vm.warp(vm.getBlockTimestamp() + AUCTION_DURATION);

        vm.expectRevert(IPredictDotLoan.AuctionNotOver.selector);
        vm.prank(lender);
        predictDotLoan.seize(1);
    }

    function test_seize_RevertIf_UnauthorizedCaller() public {
        test_call();

        vm.warp(vm.getBlockTimestamp() + AUCTION_DURATION);

        vm.expectRevert(IPredictDotLoan.UnauthorizedCaller.selector);
        predictDotLoan.seize(1);
    }

    function test_seize_RevertIf_InvalidLoanStatus_Active() public {
        testFuzz_acceptLoanOffer(0);

        vm.prank(lender);
        vm.expectRevert(IPredictDotLoan.InvalidLoanStatus.selector);
        predictDotLoan.seize(1);
    }

    function test_seize_RevertIf_InvalidLoanStatus_Defaulted() public {
        test_seize();

        vm.expectRevert(IPredictDotLoan.InvalidLoanStatus.selector);
        vm.prank(lender);
        predictDotLoan.seize(1);
    }
}
