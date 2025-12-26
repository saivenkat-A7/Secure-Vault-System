// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IAuthorizationManager {
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool);
}

contract SecureVault {
    IAuthorizationManager public authorizationManager;
    bool private initialized;

    uint256 public totalWithdrawn;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    /// @notice One-time initialization with AuthorizationManager address
    function initialize(address _authorizationManager) external {
        require(!initialized, "Already initialized");
        require(_authorizationManager != address(0), "Invalid authorization manager");

        authorizationManager = IAuthorizationManager(_authorizationManager);
        initialized = true;
    }

    /// @notice Accept ETH deposits
    receive() external payable {
        require(msg.value > 0, "Zero deposit");
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw ETH with valid authorization
    function withdraw(
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");
        require(address(this).balance >= amount, "Insufficient vault balance");

        // Ask AuthorizationManager to validate permission
        bool authorized = authorizationManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            nonce,
            signature
        );

        require(authorized, "Authorization failed");

        // CRITICAL: update state BEFORE transferring ETH
        totalWithdrawn += amount;

        // Transfer ETH
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawal(recipient, amount);
    }
}
