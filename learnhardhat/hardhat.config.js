require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
// const ALCHEMY_API_KEY = "7NdvIZaiipEarMaDaVhSACB7WgTafQGG";
// const SEPOLIA_PRIVATE_KEY = "f959d6d9646c88b9d3097aff25cfc2c199fd7c1dfe5d4e7f7e711a226c74bb9e";
const { ALCHEMY_API_KEY, SEPOLIA_PVT_KEY } = process.env;
module.exports = {
  solidity: "0.8.19",
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
