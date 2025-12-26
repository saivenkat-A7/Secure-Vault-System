# Secure Vault System

This project implements an authorization-governed vault system for controlled asset withdrawals.  
It separates **fund custody** and **permission validation** into two different smart contracts, which is a common and secure pattern used in real-world decentralized systems.

The main goal is to ensure that funds can only be withdrawn when a valid, one-time authorization is verified on-chain.

---

## Architecture

The system consists of two smart contracts:

### AuthorizationManager
- Verifies off-chain generated authorizations
- Performs signature validation
- Ensures each authorization can be used only once
- Prevents replay attacks by binding authorizations to context

### SecureVault
- Holds pooled ETH
- Accepts deposits from any address
- Executes withdrawals only after authorization approval
- Does **not** verify cryptographic signatures itself

This clear separation reduces risk and improves security.

---

## Authorization Flow

1. An off-chain signer creates an authorization containing:
   - Vault address  
   - Chain ID  
   - Recipient address  
   - Withdrawal amount  
   - Unique nonce  

2. The signed authorization is submitted to the `SecureVault`.

3. The vault forwards the request to the `AuthorizationManager`.

4. The authorization is verified and marked as used.

5. The vault updates internal state and transfers ETH to the recipient.

Each authorization is valid for **exactly one withdrawal**.

---

## Security Guarantees

- Authorizations are single-use
- Replay attacks are prevented
- Vault balance can never go negative
- State is updated before ETH transfers
- Initialization functions can run only once
- Vault logic is independent of signature verification

---

## Events and Observability

The system emits events for:
- ETH deposits
- Authorization consumption
- Successful withdrawals

This ensures transparency and traceability of all critical actions.

---

## Running with Docker

This project is fully reproducible using Docker.

### Requirements
- Docker
- Docker Compose

### Run locally
```bash
docker-compose up --build


### Manual Deployment (Without Docker)
```bash
npx hardhat run scripts/deploy.js

## Project Structure
contracts/
 ├─ AuthorizationManager.sol
 └─ SecureVault.sol

scripts/
 └─ deploy.js

docker/
 ├─ Dockerfile
 └─ entrypoint.sh

docker-compose.yml
README.md
