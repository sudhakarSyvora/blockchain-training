const { ethers } = require("hardhat");

async function main() {
  const ImplementationContract = await ethers.getContractFactory(
    "ImplementationContract"
  );
  const implementationContract = await ImplementationContract.deploy();

  const MinimalProxyContract = await ethers.getContractFactory(
    "MinimalProxyFactory"
  );
  const minimalProxyContract = await MinimalProxyContract.deploy();
  console.log("🚀 ~ main ~ minimalProxyContract:", minimalProxyContract.target);
  const deployedProxyContract = await minimalProxyContract.deployClone(
    implementationContract.target,
  );
  const deployedProxyContract1 = await minimalProxyContract.deployClone(
    implementationContract.target,
  );
  
  console.log(
    "🚀 ~ main ~ deployedProxyContract1:",
    deployedProxyContract1.data.toString()
  );
  console.log(
    "🚀 ~ main ~ deployedProxyContract:",
    deployedProxyContract.data.toString()
  );
}

main();
