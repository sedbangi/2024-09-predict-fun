// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title Provides addresses of the live contracts implementing certain interfaces.
 * @dev Examples are the Oracle or Store interfaces.
 * @notice This is a straight fork of UMA's Finder contract and we are using it for non-contracts as well.
 */
interface IAddressFinder {
    /**
     * @notice Updates the address of the contract that implements `interfaceName`.
     * @param interfaceName bytes32 encoding of the interface name that is either changed or registered.
     * @param implementationAddress address of the deployed contract that implements the interface.
     */
    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;

    /**
     * @notice Gets the address of the contract that implements the given `interfaceName`.
     * @param interfaceName queried interface.
     * @return implementationAddress address of the deployed contract that implements the interface.
     */
    function getImplementationAddress(bytes32 interfaceName) external view returns (address);
}
