const { HardhatUserConfig } =require("hardhat/config");
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
const { ETHERSCAN_API_KEY } = process.env;
/** @type import('hardhat/config').HardhatUserConfig */
const config = {
  solidity: "0.8.24",
   etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY,
    },
  },
};

module.exports={config}
