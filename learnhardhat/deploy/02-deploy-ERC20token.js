const { network } = require("hardhat");
console.log("I am second deployment script")

module.exports = async (hre) => {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    const chainId = network.config.chainId;
    
    const ERC20Token = await deploy("ERC20Token", {
        from: deployer,
        log: true,
        args: [2000, "Coins", 5, "leth"],
        waitConfirmations: chainId == 31337 ? 1 : 6,
    });
};

module.exports.tags = ["all", "ERC20Token"];