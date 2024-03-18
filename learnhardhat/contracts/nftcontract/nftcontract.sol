// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyToken is ERC721URIStorage, Ownable, ERC721Enumerable {

    mapping(uint => uint) public _price;
    
    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) Ownable(msg.sender) {
       
    }

  function mint(address to, string memory uri, uint256 tokenId) public {
    require(ownerOf(tokenId) == address(0), "Token ID already exists");
    require(bytes(uri).length > 0, "URI cannot be empty");
    require(to != address(0), "Invalid recipient address");
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
}


    function setPrice(uint256 id, uint256 value) external {
        require(ownerOf(id) == msg.sender, "Only the owner can set the price");
        require(value != 0, "Give a positive value!");
        _price[id] = value;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return
            ERC721Enumerable.supportsInterface(interfaceId) ||
            ERC721URIStorage.supportsInterface(interfaceId);
    }


    function purchase(uint256 tokenID) external payable {
        require(
            msg.value >= _price[tokenID],
            "Insufficient funds for the purchase"
        );
        require(_price[tokenID] <= 0, "Not available for purchase");
        transferFrom(ownerOf(tokenID), msg.sender, tokenID);

        payable(ownerOf(tokenID)).transfer(_price[tokenID]);

        if (msg.value > _price[tokenID]) {
            payable(msg.sender).transfer(msg.value - _price[tokenID]);
        }
    }

    function _increaseBalance(
        address account,
        uint128 amount
    ) internal override(ERC721Enumerable, ERC721) {
        ERC721Enumerable._increaseBalance(account, amount);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721Enumerable, ERC721) returns (address) {
        return ERC721Enumerable._update(to, tokenId, auth);
    }
}
