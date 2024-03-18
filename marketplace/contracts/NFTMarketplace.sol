// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFTMarketplace {
    using Address for address payable;

    struct Sale {
        address owner;
        address nftContract;
        uint256 tokenId;
        uint256 quantity;
        uint256 price;
        address paymentToken; 
    }

    mapping(uint256 => Sale) public sales;

    address public marketplaceOwner;
    uint256 public feePercentage = 55;

    event SaleCreated(uint256 saleId, address indexed owner, address indexed nftContract, uint256 indexed tokenId, uint256 quantity, uint256 price, address paymentToken);
    event SaleUpdated(uint256 saleId, address indexed owner, uint256 price);
    event SaleCompleted(uint256 saleId, address indexed buyer, uint256 price);

    constructor(address _nftContract) {
        marketplaceOwner = msg.sender;
        IERC1155 nftContract = IERC1155(_nftContract);
        nftContract.setApprovalForAll(address(this), true);
    }

    modifier onlyNFTOwner(address _nftContract, uint256 _tokenId) {
        address tokenOwner;
        if (IERC721(_nftContract).supportsInterface(0x80ac58cd)) {  
            tokenOwner = IERC721(_nftContract).ownerOf(_tokenId);
        } else {
            tokenOwner = IERC1155(_nftContract).balanceOf(msg.sender, _tokenId) > 0 ? msg.sender : address(0);
        }
        require(tokenOwner == msg.sender, "Only NFT owner can perform this action");
        _;
    }

    function createOrUpdateSale(
        address _nftContract,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _price,
        address _paymentToken
        
    ) external onlyNFTOwner(_nftContract,_tokenId)  {
        require(_nftContract != address(0), "Invalid contract address");
        require(_quantity > 0, "Quantity should be greater than zero");
        require(_price > 0, "Price should be greater than zero");

        if (sales[_tokenId].owner == address(0)) {
            sales[_tokenId] = Sale(msg.sender, _nftContract, _tokenId, _quantity, _price, _paymentToken);
            emit SaleCreated(_tokenId, msg.sender, _nftContract, _tokenId, _quantity, _price, _paymentToken);
        } else {
            sales[_tokenId].price = _price;
            emit SaleUpdated(_tokenId, msg.sender, _price);
        }
    }

    function buy(uint256 _tokenId) external payable {
        Sale storage sale = sales[_tokenId];
        require(sale.owner != address(0), "Sale does not exist");

        uint256 totalPrice = sale.price;
        if (sale.paymentToken == address(0)) {
            require(msg.value >= totalPrice, "Insufficient ETH sent");
        } else {
            require(msg.value == 0, "ETH not allowed for this sale");
            IERC20 paymentToken = IERC20(sale.paymentToken);
            require(paymentToken.transferFrom(msg.sender, address(this), totalPrice), "Payment transfer failed");
        }

        uint256 feeAmount = totalPrice * feePercentage / 10000;
        payable(sale.owner).sendValue(totalPrice - feeAmount); 
        payable(marketplaceOwner).sendValue(feeAmount); 

        if (IERC721(sale.nftContract).supportsInterface(0x80ac58cd)) { 
            IERC721(sale.nftContract).safeTransferFrom(sale.owner, msg.sender, _tokenId);
        } else {
            IERC1155(sale.nftContract).safeTransferFrom(sale.owner, msg.sender, _tokenId, sale.quantity, "");
        }

        delete sales[_tokenId];

        emit SaleCompleted(_tokenId, msg.sender, totalPrice);
    }

}
