// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IPredictDotLoan} from "../../contracts/interfaces/IPredictDotLoan.sol";
import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_Cancel_Test is PredictDotLoan_Test {
    function testFuzz_cancel(bool lending, bool borrowing) public {
        vm.assume(lending || borrowing);

        IPredictDotLoan.SaltCancellationRequest[] memory requests = new IPredictDotLoan.SaltCancellationRequest[](3);
        requests[0] = IPredictDotLoan.SaltCancellationRequest(1, lending, borrowing);
        requests[1] = IPredictDotLoan.SaltCancellationRequest(2, lending, borrowing);
        requests[2] = IPredictDotLoan.SaltCancellationRequest(3, lending, borrowing);

        expectEmitCheckAll();
        emit SaltsCancelled(whiteKnight, requests);

        vm.prank(whiteKnight);
        predictDotLoan.cancel(requests);

        (bool _lending, bool _borrowing) = predictDotLoan.saltCancellations(whiteKnight, 1);
        assertEq(_lending, lending);
        assertEq(_borrowing, borrowing);

        (_lending, _borrowing) = predictDotLoan.saltCancellations(whiteKnight, 2);
        assertEq(_lending, lending);
        assertEq(_borrowing, borrowing);

        (_lending, _borrowing) = predictDotLoan.saltCancellations(whiteKnight, 3);
        assertEq(_lending, lending);
        assertEq(_borrowing, borrowing);
    }

    function test_cancel_RevertIf_SaltAlreadyCancelled_Lending() public {
        IPredictDotLoan.SaltCancellationRequest[] memory requests = new IPredictDotLoan.SaltCancellationRequest[](3);
        requests[0] = IPredictDotLoan.SaltCancellationRequest(1, true, false);
        requests[1] = IPredictDotLoan.SaltCancellationRequest(2, true, false);
        requests[2] = IPredictDotLoan.SaltCancellationRequest(3, true, false);

        vm.prank(whiteKnight);
        predictDotLoan.cancel(requests);

        vm.expectRevert(abi.encodeWithSelector(IPredictDotLoan.SaltAlreadyCancelled.selector, 1));
        vm.prank(whiteKnight);
        predictDotLoan.cancel(requests);
    }

    function test_cancel_RevertIf_SaltAlreadyCancelled_Borrow() public {
        IPredictDotLoan.SaltCancellationRequest[] memory requests = new IPredictDotLoan.SaltCancellationRequest[](3);
        requests[0] = IPredictDotLoan.SaltCancellationRequest(1, false, true);
        requests[1] = IPredictDotLoan.SaltCancellationRequest(2, false, true);
        requests[2] = IPredictDotLoan.SaltCancellationRequest(3, false, true);

        vm.prank(whiteKnight);
        predictDotLoan.cancel(requests);

        vm.expectRevert(abi.encodeWithSelector(IPredictDotLoan.SaltAlreadyCancelled.selector, 1));
        vm.prank(whiteKnight);
        predictDotLoan.cancel(requests);
    }

    function test_cancel_RevertIf_NoSaltCancellationRequests() public {
        vm.expectRevert(abi.encodeWithSelector(IPredictDotLoan.NoSaltCancellationRequests.selector));
        vm.prank(whiteKnight);
        predictDotLoan.cancel(new IPredictDotLoan.SaltCancellationRequest[](0));
    }

    function test_cancel_RevertIf_NotCancelling() public {
        IPredictDotLoan.SaltCancellationRequest[] memory requests = new IPredictDotLoan.SaltCancellationRequest[](1);
        requests[0] = IPredictDotLoan.SaltCancellationRequest(1, false, false);

        vm.expectRevert(abi.encodeWithSelector(IPredictDotLoan.NotCancelling.selector));
        vm.prank(whiteKnight);
        predictDotLoan.cancel(requests);
    }
}
