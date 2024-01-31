require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");
/** @type import('hardhat/config').HardhatUserConfig */

const { ALCHEMY_API_KEY, SEPOLIA_PVT_KEY } = process.env;
module.exports = {
  solidity: "0.8.20",
  defaultNetwork: "hardhat",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [SEPOLIA_PVT_KEY],
      saveDeployments: true,
    },
    hardhat: {
      chainId: 31337,
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  },
};
