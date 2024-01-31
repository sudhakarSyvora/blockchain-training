require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require('hardhat-deploy');
/** @type import('hardhat/config').HardhatUserConfig */
 
const { ALCHEMY_API_KEY, SEPOLIA_PVT_KEY } = process.env;
module.exports = {
  solidity: "0.8.20",
  defaultNetwork: "sepolia",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${SEPOLIA_PVT_KEY}`],
    },
  },
  etherscan:{
    apiKey:process.env.ETHERSCAN_KEY
  }
};
