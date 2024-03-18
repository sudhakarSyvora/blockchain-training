// TypeScript
import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { network } from "hardhat";

const deployContracts: DeployFunction = async (
    hre: HardhatRuntimeEnvironment
) => {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    const chainId = network.config.chainId!;

 
    const gameItemsResult = await deploy("GameItems", {
        from: deployer,
        log: true,
        args: [],
        waitConfirmations: chainId == 31337 ? 1 : 3,
    });

   
    await deploy("NFTMarketplace", {
        from: deployer,
        log: true,
        args: [gameItemsResult.address], 
        waitConfirmations: chainId == 31337 ? 1 : 3,
    });
};

export default deployContracts;
