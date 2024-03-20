# NFT Marketplace

This is a decentralized NFT (Non-Fungible Token) marketplace smart contract implemented in Solidity. The contract allows users to create sales for their NFTs and enables other users to buy them using either Ether or ERC20 tokens.

## Features

- **Create Sales**: Users can create sales for their NFTs by specifying the NFT contract address, token ID, quantity (if applicable), price, and payment token.
- **Buy NFTs**: Users can purchase NFTs listed for sale using either Ether or ERC20 tokens.
- **Fee Handling**: The contract automatically deducts a fee from the purchase price and handles refunds for any excess payment made by the buyer.
- **Flexible Token Support**: The contract supports both ERC721 and ERC1155 tokens.

## Getting Started

1. Clone this repository:

   git clone <repository-url>

2. Install dependencies:
   npm install

3. Compile the smart contracts:
   npx hardhat compile

4. Run tests:
   npx hardhat test

## Usage

### Creating a Sale

To create a sale for an NFT, call the `createOrUpdateSale` function with the following parameters:

- `_nftContract`: Address of the NFT contract
- `_tokenId`: ID of the token to be sold
- `_quantity`: Quantity of tokens (if ERC1155)
- `_price`: Price of the token(s)
- `_paymentToken`: Address of the payment token (use `0x0` for Ether)

### Buying an NFT

To buy an NFT listed for sale, call the `buy` function with the following parameters:

- `_nftContract`: Address of the NFT contract
- `_tokenId`: ID of the token to be bought

### Fees

A fee is deducted from the purchase price in both Ether and token transactions. The fee percentage can be configured during contract deployment.
