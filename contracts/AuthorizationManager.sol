// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AuthorizationManager {
    using ECDSA for bytes32;

    address public signer;
    bool private initialized;

    // Tracks whether an authorization hash has already been used
    mapping(bytes32 => bool) public authorizationUsed;

    event AuthorizationConsumed(
        bytes32 indexed authorizationHash,
        address indexed vault,
        address indexed recipient,
        uint256 amount
    );

    /// @notice One-time initialization of the trusted signer
    function initialize(address _signer) external {
        require(!initialized, "Already initialized");
        require(_signer != address(0), "Invalid signer");

        signer = _signer;
        initialized = true;
    }

    /// @notice Verify and consume a withdrawal authorization
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool) {
        require(vault != address(0), "Invalid vault");
        require(recipient != address(0), "Invalid recipient");

        // Authorization is tightly bound to context
        bytes32 authorizationHash = keccak256(
            abi.encode(
                vault,
                block.chainid,
                recipient,
                amount,
                nonce
            )
        );

        require(!authorizationUsed[authorizationHash], "Authorization already used");

        // Recover signer from off-chain signature
       bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(authorizationHash);
        address recoveredSigner = ethSignedHash.recover(signature);

        require(recoveredSigner == signer, "Invalid signature");

        // CRITICAL: mark authorization as used BEFORE returning
        authorizationUsed[authorizationHash] = true;

        emit AuthorizationConsumed(
            authorizationHash,
            vault,
            recipient,
            amount
        );

        return true;
    }
}

