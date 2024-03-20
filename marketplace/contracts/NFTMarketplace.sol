// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title NFT Marketplace Contract
/// @notice This contract allows users to buy and sell NFTs (ERC721 and ERC1155 tokens) on a decentralized marketplace.
contract NFTMarketplace is Ownable {
    enum ContractType {
        ERC721,
        ERC1155
    }

    struct Sale {
        address owner;
        address nftContract;
        address paymentToken;
        uint256 tokenId;
        uint256 quantity;
        uint256 price;
        ContractType contractType;
    }

    // Address of the marketplace owner who receives fees
    address public marketplaceOwner;

    // Percentage of fees charged by the marketplace
    uint256 public feePercentage;

    // Mapping to store sale details for each NFT contract and token ID
    mapping(address => mapping(uint256 => Sale)) public sales;

    // Events to track sale creation, updates, and completions
    event SaleCreated(
        address owner,
        address nftContract,
        address paymentToken,
        uint256 tokenId,
        uint256 quantity,
        uint256 price,
        ContractType contractType
    );
    event SaleUpdated(address owner, uint256 tokenId, uint256 price);
    event SaleCompleted(address buyer, uint256 tokenId, uint256 price);
    event FeeUpdated(uint256 _newFee);

    /// @notice Constructor function to initialize the marketplace owner and fee percentage
    /// @param _feePercentage The percentage of fees charged by the marketplace
    constructor(uint256 _feePercentage) Ownable(msg.sender) {
        marketplaceOwner = msg.sender;
        feePercentage = _feePercentage;
    }

    /// @notice Function to create or update a sale for an NFT
    /// @param _nftContract Address of the NFT contract
    /// @param _tokenId ID of the token
    /// @param _quantity Quantity of tokens being sold (for ERC1155)
    /// @param _price Sale price of the NFT
    /// @param _paymentToken Address of the ERC20 token used for payment
    function createOrUpdateSale(
        address _nftContract,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _price,
        address _paymentToken
    ) external {
        require(_nftContract != address(0), "Invalid contract address");
        require(_quantity > 0, "Quantity should be greater than zero");
        require(_price > 0, "Price should be greater than zero");

        (address tokenOwner, ContractType contractType) = findNFTOwnerAndType(
            _nftContract,
            _tokenId
        );
        require(
            tokenOwner == msg.sender,
            "Only NFT owner can perform this action"
        );

        if (sales[_nftContract][_tokenId].owner == address(0)) {
            if (contractType == ContractType.ERC721) {
                require(
                    IERC721(_nftContract).isApprovedForAll(
                        tokenOwner,
                        address(this)
                    ),
                    "Approval not provided for ERC721 transfer"
                );
            } else if (contractType == ContractType.ERC1155) {
                require(
                    IERC1155(_nftContract).isApprovedForAll(
                        tokenOwner,
                        address(this)
                    ),
                    "Approval not provided for ERC1155 transfer"
                );
            }
            sales[_nftContract][_tokenId] = Sale(
                msg.sender,
                _nftContract,
                _paymentToken,
                _tokenId,
                _quantity,
                _price,
                contractType
            );
            emit SaleCreated(
                msg.sender,
                _nftContract,
                _paymentToken,
                _tokenId,
                _quantity,
                _price,
                contractType
            );
        } else {
            sales[_nftContract][_tokenId].price = _price;
            emit SaleUpdated(msg.sender, _tokenId, _price);
        }
    }

    /// @notice Function to buy an NFT from the marketplace
    /// @param _nftContract Address of the NFT contract
    /// @param _tokenId ID of the token
    function buy(address _nftContract, uint256 _tokenId) external payable {
        Sale memory sale = sales[_nftContract][_tokenId];
        require(sale.owner != address(0), "Sale does not exist");

        uint256 totalPrice = sale.price;
        uint256 feeAmount = (totalPrice * feePercentage) / 10000;
        if (sale.paymentToken == address(0)) {
            require(msg.value >= totalPrice, "Insufficient ETH sent");
            payable(sale.owner).transfer(totalPrice - feeAmount);
            payable(marketplaceOwner).transfer(feeAmount);
            uint256 excessPayment = msg.value - totalPrice;
            if (excessPayment > 0) {
                payable(msg.sender).transfer(excessPayment);
            }
        } else {
            payable(msg.sender).transfer(msg.value);
            IERC20 paymentToken = IERC20(sale.paymentToken);
            require(
                paymentToken.allowance(msg.sender, address(this)) >= totalPrice,
                "Allowance not provided to contract to spend tokens"
            );
            require(
                paymentToken.transferFrom(
                    msg.sender,
                    sale.owner,
                    totalPrice - feeAmount
                ),
                "Payment transfer failed"
            );
            require(
                paymentToken.transferFrom(
                    msg.sender,
                    marketplaceOwner,
                    feeAmount
                ),
                "Fee transfer failed"
            );
        }

        if (sale.contractType == ContractType.ERC721) {
            IERC721(sale.nftContract).safeTransferFrom(
                sale.owner,
                msg.sender,
                _tokenId
            );
        } else if (sale.contractType == ContractType.ERC1155) {
            IERC1155(sale.nftContract).safeTransferFrom(
                sale.owner,
                msg.sender,
                _tokenId,
                sale.quantity,
                ""
            );
        } else {
            revert("Invalid contract type");
        }

        sales[_nftContract][_tokenId].owner = msg.sender;

        emit SaleCompleted(msg.sender, _tokenId, totalPrice);
    }

    function setFee(uint256 _newFee) external onlyOwner {
        feePercentage = _newFee;
        emit FeeUpdated(_newFee);
    }

    function findNFTOwnerAndType(
        address _nftContract,
        uint256 _tokenId
    ) internal view returns (address, ContractType) {
        if (
            IERC721(_nftContract).supportsInterface(type(IERC721).interfaceId)
        ) {
            return (
                IERC721(_nftContract).ownerOf(_tokenId),
                ContractType.ERC721
            );
        } else if (
            IERC1155(_nftContract).supportsInterface(type(IERC1155).interfaceId)
        ) {
            return (
                IERC1155(_nftContract).balanceOf(msg.sender, _tokenId) > 0
                    ? msg.sender
                    : address(0),
                ContractType.ERC1155
            );
        } else {
            revert("NFT contract does not support ERC721 or ERC1155 interface");
        }
    }
}
