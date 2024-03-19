// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace {
    struct Sale {
        address owner;
        address nftContract;
        uint256 tokenId;
        uint256 quantity;
        uint256 price;
        address paymentToken;
    }

    mapping(address => mapping(uint256 => Sale)) public sales;
    address public marketplaceOwner;
    uint256 public feePercentage;

    event SaleCreated(
        address indexed owner,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 quantity,
        uint256 price,
        address paymentToken
    );
    event SaleUpdated(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 price
    );
    event SaleCompleted(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 price
    );

    constructor(uint256 _feePercentage) {
        marketplaceOwner = msg.sender;
        feePercentage = _feePercentage;
    }

    modifier onlyNFTOwner(address _nftContract, uint256 _tokenId) {
        address tokenOwner;
        if (IERC721(_nftContract).supportsInterface(0x80ac58cd)) {
            tokenOwner = IERC721(_nftContract).ownerOf(_tokenId);
        } else {
            tokenOwner = IERC1155(_nftContract).balanceOf(
                msg.sender,
                _tokenId
            ) > 0
                ? msg.sender
                : address(0);
        }
        require(
            tokenOwner == msg.sender,
            "Only NFT owner can perform this action"
        );
        _;
    }

    function createOrUpdateSale(
        address _nftContract,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _price,
        address _paymentToken
    ) external onlyNFTOwner(_nftContract, _tokenId) {
        require(_nftContract != address(0), "Invalid contract address");
        require(_quantity > 0, "Quantity should be greater than zero");
        require(_price > 0, "Price should be greater than zero");

        if (sales[_nftContract][_tokenId].owner == address(0)) {
            sales[_nftContract][_tokenId] = Sale(
                msg.sender,
                _nftContract,
                _tokenId,
                _quantity,
                _price,
                _paymentToken
            );
            emit SaleCreated(
                msg.sender,
                _nftContract,
                _tokenId,
                _quantity,
                _price,
                _paymentToken
            );
        } else {
            sales[_nftContract][_tokenId].price = _price;
            emit SaleUpdated(msg.sender, _tokenId, _price);
        }
    }

    function buy(address _nftContract, uint256 _tokenId) external payable {
        Sale storage sale = sales[_nftContract][_tokenId];
        require(sale.owner != address(0), "Sale does not exist");

        uint256 totalPrice = sale.price;
        uint256 feeAmount = (totalPrice * feePercentage) / 10000;
        if (sale.paymentToken == address(0)) {
            require(msg.value >= totalPrice, "Insufficient ETH sent");
            payable(sale.owner).transfer(totalPrice - feeAmount);
        } else {
            IERC20 paymentToken = IERC20(sale.paymentToken);
            require(
                paymentToken.allowance(msg.sender, address(this)) >= totalPrice,
                "Allowance not provided"
            );
            require(
                paymentToken.transferFrom(msg.sender, sale.owner, totalPrice),
                "Payment transfer failed"
            );
        }

        payable(marketplaceOwner).transfer(feeAmount);
        uint256 excessPayment = msg.value - totalPrice;

        if (excessPayment > 0) {
            payable(msg.sender).transfer(excessPayment);
        }
        if (
            IERC721(sale.nftContract).supportsInterface(
                type(IERC721).interfaceId
            )
        ) {
            IERC721(sale.nftContract).safeTransferFrom(
                sale.owner,
                msg.sender,
                _tokenId
            );
        } else {
            IERC1155(sale.nftContract).safeTransferFrom(
                sale.owner,
                msg.sender,
                _tokenId,
                sale.quantity,
                ""
            );
        }
        sales[_nftContract][_tokenId].owner = msg.sender;

        emit SaleCompleted(msg.sender, _tokenId, totalPrice);
    }
}
