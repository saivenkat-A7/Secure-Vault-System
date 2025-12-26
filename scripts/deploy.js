const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const network = await hre.ethers.provider.getNetwork();

  console.log("Deployer:", deployer.address);
  console.log("Network chainId:", network.chainId);

  // Deploy AuthorizationManager
  const AuthorizationManager = await hre.ethers.getContractFactory(
    "AuthorizationManager"
  );
  const authManager = await AuthorizationManager.deploy();
  await authManager.waitForDeployment();

  console.log(
    "AuthorizationManager deployed to:",
    await authManager.getAddress()
  );

  // Initialize AuthorizationManager
  await authManager.initialize(deployer.address);

  // Deploy SecureVault
  const SecureVault = await hre.ethers.getContractFactory("SecureVault");
  const vault = await SecureVault.deploy();
  await vault.waitForDeployment();

  console.log("SecureVault deployed to:", await vault.getAddress());

  // Initialize SecureVault
  await vault.initialize(await authManager.getAddress());

  console.log("Deployment completed successfully");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
