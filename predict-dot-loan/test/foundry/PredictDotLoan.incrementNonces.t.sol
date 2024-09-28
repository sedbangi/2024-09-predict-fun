// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IPredictDotLoan} from "../../contracts/interfaces/IPredictDotLoan.sol";

import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_IncrementNonces_Test is PredictDotLoan_Test {
    function test_incrementNonces_OnlyLendingNonce() public asPrankedUser(lender) {
        expectEmitCheckAll();
        emit NoncesIncremented(1, 0);

        predictDotLoan.incrementNonces(true, false);

        (uint256 lendingNonce, uint256 borrowingNonce) = predictDotLoan.nonces(lender);
        assertEq(lendingNonce, 1);
        assertEq(borrowingNonce, 0);
    }

    function test_incrementNonces_OnlyBorrowingNonce() public asPrankedUser(borrower) {
        expectEmitCheckAll();
        emit NoncesIncremented(0, 1);

        predictDotLoan.incrementNonces(false, true);

        (uint256 lendingNonce, uint256 borrowingNonce) = predictDotLoan.nonces(borrower);
        assertEq(lendingNonce, 0);
        assertEq(borrowingNonce, 1);
    }

    function test_incrementNonces_BothNonces() public asPrankedUser(whiteKnight) {
        expectEmitCheckAll();
        emit NoncesIncremented(1, 1);

        predictDotLoan.incrementNonces(true, true);

        (uint256 lendingNonce, uint256 borrowingNonce) = predictDotLoan.nonces(whiteKnight);
        assertEq(lendingNonce, 1);
        assertEq(borrowingNonce, 1);
    }

    function test_incrementNonces_NotIncrementing() public {
        vm.expectRevert(IPredictDotLoan.NotIncrementing.selector);
        predictDotLoan.incrementNonces(false, false);
    }
}
