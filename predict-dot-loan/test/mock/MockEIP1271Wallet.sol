// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract MockEIP1271Wallet is Ownable, ERC1155Holder {
    constructor(address originalOwner) Ownable(originalOwner) {}

    function isValidSignature(bytes32 hash, bytes memory signature) public view returns (bytes4 magicValue) {
        return ECDSA.recover(hash, signature) == owner() ? this.isValidSignature.selector : bytes4(0);
    }
}
