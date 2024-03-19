const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require('ethers')
let zeroAddress = "0x0000000000000000000000000000000000000000";
describe("NFTMarketplace", function () {
  let NFTMarketplace: any;
  let nftMarketplace: any;
  let owner: any;
  let addr1: any;
  let addr2: any;
  let erc721Token: any;
  let erc1155Token: any;
  const provider = ethers.getDefaultProvider();

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    nftMarketplace = await NFTMarketplace.deploy(100); 

    
    const ERC721Mock = await ethers.getContractFactory("MyERC721"); 
    erc721Token = await ERC721Mock.deploy("NFT", "NFT");

    const ERC1155Mock = await ethers.getContractFactory("MyERC1155"); 
    erc1155Token = await ERC1155Mock.deploy();

    
    await erc721Token.mint(owner.address, 1); 
    await erc1155Token.mint(
      owner.address,
      1,
      5,
      "0x0000000000000000000000000000000000000000"
    ); 
    await erc721Token.connect(owner).setApprovalForAll(nftMarketplace.target, true);
    await erc1155Token.connect(owner).setApprovalForAll(nftMarketplace.target, true);
  });

  describe("createOrUpdateSale", function () {
    it("should create a sale for ERC721 token", async function () {
      const tokenId = 1;
      const price = ethers.parseEther("1");  
      console.log(erc721Token.target, "target");
      await expect(
        nftMarketplace.createOrUpdateSale(
          erc721Token.target,
          tokenId,
          1,  
          price,
          zeroAddress  
        )
      )
        .to.emit(nftMarketplace, "SaleCreated")
        .withArgs(
          owner.address,
          erc721Token.target,
          tokenId,
          1,
          price,
          zeroAddress
        );
    });

    it("should create a sale for ERC1155 token", async function () {
      const tokenId = 1;
      const quantity = 5;
      const price = ethers.parseEther("1"); 

      await expect(
        nftMarketplace.createOrUpdateSale(
          erc1155Token.target,
          tokenId,
          quantity,
          price,
        zeroAddress 
        )
      )
        .to.emit(nftMarketplace, "SaleCreated")
        .withArgs(
          owner.address,
          erc1155Token.target,
          tokenId,
          quantity,
          price,
        zeroAddress
        );
    });
  });

  describe("buy", function () {
    it("should allow a user to buy an ERC721 token", async function () {
      const tokenId = 1;
      const price = ethers.parseEther("1");  

      await nftMarketplace.createOrUpdateSale(
        erc721Token.target,
        tokenId,
        1,  
        price,
        zeroAddress 
      );

      const initialOwnerBalance = await provider.getBalance(addr1);
      const initialOwnerBalanceBigNumber = BigInt(initialOwnerBalance);


      await expect(
        nftMarketplace
          .connect(addr1)
          .buy(erc721Token.target, tokenId, { value: price })
      )
        .to.emit(nftMarketplace, "SaleCompleted")
        .withArgs(addr1.address, tokenId, price);

        const finalOwnerBalance = await provider.getBalance(addr1);
        const finalOwnerBalanceBigNumber = BigInt(finalOwnerBalance);
        const ownerBalanceDifference = finalOwnerBalanceBigNumber-initialOwnerBalanceBigNumber;

        expect(ownerBalanceDifference).to.equal(price*BigInt(99)/BigInt(100));


       

      const newOwner = await erc721Token.ownerOf(tokenId);
      expect(newOwner).to.equal(addr1.address);
    });

    it("should allow a user to buy an ERC1155 token", async function () {
      const tokenId = 1;
      const quantity = 5;
      const price = ethers.parseEther("1");  

      await nftMarketplace.createOrUpdateSale(
        erc1155Token.target,
        tokenId,
        quantity,
        price,
        zeroAddress  
      );

      const initialOwnerBalance = await provider.getBalance(owner.address);
      const initialOwnerBalanceBigNumber = BigInt(initialOwnerBalance);

      await expect(
        nftMarketplace
          .connect(addr1)
          .buy(erc1155Token.target, tokenId, { value: price })
      )
        .to.emit(nftMarketplace, "SaleCompleted")
        .withArgs(addr1.address, tokenId, price);

      const finalOwnerBalance = await provider.getBalance(owner.address);
      const finalOwnerBalanceBigNumber = BigInt(finalOwnerBalance.toString());
      const ownerBalanceDifference = finalOwnerBalanceBigNumber-(initialOwnerBalanceBigNumber);

      expect(ownerBalanceDifference).to.equal(price*BigInt(99)/BigInt(100)); 

      const newOwnerBalance = await erc1155Token.balanceOf(
        addr1.address,
        tokenId
      );
      expect(newOwnerBalance).to.equal(quantity);
    });
  });

});
