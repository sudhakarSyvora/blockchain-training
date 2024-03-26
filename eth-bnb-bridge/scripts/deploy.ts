const { ethers } = require("hardhat");
require("dotenv").config();
const { PrivateKey, alchemyEthUrl } = process.env;
console.log("🚀 ~ alchemyEthUrl:", alchemyEthUrl)

const ethProvider = new ethers.JsonRpcProvider(alchemyEthUrl);
const ethWallet = new ethers.Wallet(PrivateKey, ethProvider);

const bscTestnetUrl = "https://data-seed-prebsc-1-s1.binance.org:8545";
const bscProvider = new ethers.JsonRpcProvider(bscTestnetUrl);
const bscWallet = new ethers.Wallet(PrivateKey, bscProvider);

async function deployTokenAndBridgeEth() {
  const TokenEthFactory = await ethers.getContractFactory("TokenEth", ethWallet);
  const tokenEth = await TokenEthFactory.deploy();

  const BridgeEthFactory = await ethers.getContractFactory("BridgeEth", ethWallet);
  const bridgeEth = await BridgeEthFactory.deploy(tokenEth.target);

  console.log("TokenEth deployed to:", tokenEth.target);
  console.log("BridgeEth deployed to:", bridgeEth.target);

  return { tokenEth, bridgeEth };
}

async function deployTokenAndBridgeBsc() {
  const TokenBscFactory = await ethers.getContractFactory("TokenBsc", bscWallet);
  const tokenBsc = await TokenBscFactory.deploy();

  const BridgeBscFactory = await ethers.getContractFactory("BridgeBsc", bscWallet);
  const bridgeBsc = await BridgeBscFactory.deploy(tokenBsc.target);

  console.log("TokenBsc deployed to:", tokenBsc.target);
  console.log("BridgeBsc deployed to:", bridgeBsc.target);

  return { tokenBsc, bridgeBsc };
}

async function main() {
  const { tokenEth, bridgeEth } = await deployTokenAndBridgeEth();
  const { tokenBsc, bridgeBsc } = await deployTokenAndBridgeBsc();
  await bridgeEth.mint(ethWallet.address, 100, 0);  
  console.log("Minted 100 tokens to BridgeEth");

 
// bridgeEth.on("Transfer", async (from: string, to: string, amount: number, date: number, nonce: number, step: number) => {
//   console.log("Transfer event received from BridgeEth:");
//   console.log("From:", from);
//   console.log("To:", to);
//   console.log("Amount:", amount);
//   console.log("Date:", date);
//   console.log("Nonce:", nonce);
//   console.log("Step:", step);

//   if (step === 1) {
 
//     await bridgeBsc.burn(to, amount, nonce);
//     console.log("BridgeBsc.burn called with parameters:", to, amount, nonce);
//   }
// });
bridgeEth.on("Transfer", async (h) => {
  console.log(h)
});

  // bridgeBsc.on("Transfer", async (from: string, to: string, amount: number, date: number, nonce: number, step: number) => {
  //   console.log("Transfer event received from BridgeBsc:");
  //   console.log("From:", from);
  //   console.log("To:", to);
  //   console.log("Amount:", amount);
  //   console.log("Date:", date);
  //   console.log("Nonce:", nonce);
  //   console.log("Step:", step);

  //   await bridgeEth.mint(to, amount, nonce);
  //   console.log("BridgeEth.mint called with parameters:", to, amount, nonce);
  // });
}


main()
