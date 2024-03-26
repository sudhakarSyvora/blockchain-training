const { ethers, upgrades } = require("hardhat");
async function main() {
  const NUM1 = await ethers.getContractFactory("NUM1");

  const num1 = await upgrades.deployProxy(NUM1, [10], {
    initializer: "update",
  });
 await num1.waitForDeployment()
  console.log("num1 address", num1.target);
}
main();
//0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512