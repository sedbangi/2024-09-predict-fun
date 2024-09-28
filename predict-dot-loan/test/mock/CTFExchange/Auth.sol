// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title Auth
/// @notice Provides admin and operator roles and access control modifiers
abstract contract Auth {
    /// @dev The set of addresses authorized as Admins
    mapping(address => uint256) public admins;

    /// @dev The set of addresses authorized as Operators
    mapping(address => uint256) public operators;

    error NotAdmin();
    error NotOperator();

    modifier onlyAdmin() {
        if (admins[msg.sender] != 1) revert NotAdmin();
        _;
    }

    modifier onlyOperator() {
        if (operators[msg.sender] != 1) revert NotOperator();
        _;
    }

    constructor() {
        admins[msg.sender] = 1;
        operators[msg.sender] = 1;
    }

    /// @notice Adds a new admin
    /// Can only be called by a current admin
    /// @param admin_ - The new admin
    function addAdmin(address admin_) external {
        admins[admin_] = 1;
    }

    /// @notice Adds a new operator
    /// Can only be called by a current admin
    /// @param operator_ - The new operator
    function addOperator(address operator_) external {
        operators[operator_] = 1;
    }

    /// @notice Removes a new admin
    /// Can only be called by a current admin
    /// @param admin_ - The new admin
    function removeAdmin(address admin_) external {
        admins[admin_] = 0;
    }

    /// @notice Removes a new operator
    /// Can only be called by a current admin
    /// @param operator_ - The new operator
    function removeOperator(address operator_) external {
        operators[operator_] = 0;
    }
}
