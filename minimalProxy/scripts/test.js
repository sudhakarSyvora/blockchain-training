const { ethers } = require("hardhat");

async function main() {
    const c1 = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const C1 = await ethers.getContractAt("MinimalProxyFactory", c1);
 
    const proxies = await C1.initData().toString();

    console.log("Proxies:", proxies);
}

main();
