// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {MockERC1155} from "../mock/MockERC1155.sol";

import {IPredictDotLoan} from "../../contracts/interfaces/IPredictDotLoan.sol";
import {PredictDotLoan_Test} from "./PredictDotLoan.t.sol";

contract PredictDotLoan_OnERC1155Received_Test is PredictDotLoan_Test {
    function test_onERC1155Received_RevertIf_ContractOnlyAcceptsCTF() public {
        MockERC1155 token = new MockERC1155();

        vm.expectRevert(IPredictDotLoan.ContractOnlyAcceptsCTF.selector);
        token.mint(address(predictDotLoan), 1, 1);
    }

    function test_onERC1155BatchReceived_RevertIf_ContractOnlyAcceptsCTF() public {
        MockERC1155 token = new MockERC1155();

        uint256[] memory ids = new uint256[](2);
        uint256[] memory values = new uint256[](2);

        ids[0] = 1;
        values[0] = 1;

        ids[1] = 2;
        values[1] = 2;

        vm.expectRevert(IPredictDotLoan.ContractOnlyAcceptsCTF.selector);
        token.mintBatch(address(predictDotLoan), ids, values);
    }
}
