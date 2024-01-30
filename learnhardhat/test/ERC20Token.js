const { expect } = require("chai");

describe("Token Contract", function () {
  let Token;
  let hardhatToken;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  beforeEach(async function () {
    Token = await ethers.getContractFactory("ERC20Token");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    hardhatToken = await Token.deploy(1000, "Coins", 5, "leth");
  });
  describe("Deployment", () => {
    it("Should have correct totalSupply", async () => {
      expect(await hardhatToken.totalSupply()).to.equal(1000);
    });
    it("Should have correct name", async () => {
      expect(await hardhatToken.name()).to.equal("Coins");
    });
    it("Should have correct decimal places", async () => {
      expect(await hardhatToken.decimals()).to.equal(5);
    });
    it("Should have correct name", async () => {
      expect(await hardhatToken.symbol()).to.equal("leth");
    });
  });
  describe("Transfer", () => {
    it("Should transfer tokens successfully", async () => {
      const amount = 10;
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      await hardhatToken.transfer(addr2.address, amount);
      expect(await hardhatToken.balanceOf(owner.address)).to.eq(
        ownerBalance - BigInt(amount)
      );
      expect(await hardhatToken.balanceOf(addr2)).to.eq(amount);
    });
    it("Should fail if sender has insufficient balance", async function () {
      await expect(
        hardhatToken.connect(addr1).transfer(addr2.address, 100)
      ).to.be.revertedWith("ERC20: Insufficient balance");
    });
  });
  describe("TransferFrom", () => {
    it("Should transfer tokens using allowance", async () => {
      await hardhatToken.approve(addr1.address, 30);
      await hardhatToken
        .connect(addr1)
        .transferFrom(owner.address, addr2.address, 10);
      expect(await hardhatToken.balanceOf(owner.address)).to.eq(9990);
      expect(await hardhatToken.balanceOf(addr2.address)).to.eq(10);
    });
    it('Should have approved the "spender"', async () => {
      await hardhatToken.approve(addr1.address, 10);
      const allowance = await hardhatToken.allowance(owner.address, addr1.address);
      expect(allowance).to.equal(10);
    });
    it("Should not be able to exceed allowance", async () => {
      await hardhatToken.approve(addr1.address, 30);
      await expect(
        hardhatToken
          .connect(addr1)
          .transferFrom(owner.address, addr2.address, 40)
      ).to.be.revertedWith("Not approved");
    });
  });
  describe("Minting new coins", () => {
    it("Should mint coins when called by owner", async () => {
      await hardhatToken.mint(addr1.address, 30);
      const balanceAfterMint = await hardhatToken.balanceOf(addr1.address);
      expect(balanceAfterMint).to.eq(30);
    });
  });
});
