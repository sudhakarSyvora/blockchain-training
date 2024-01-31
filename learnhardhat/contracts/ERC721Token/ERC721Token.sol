// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

 
import "../ERC20Token/ERC20Token.sol";

 
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
 

// Your ERC20Token contract
 contract ERC721 is IERC721 {

    // Mapping from token ID to owner address
    mapping(uint => address) internal _ownerOf;

    // Mapping owner address to token count
    mapping(address => uint) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint => address) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    //Mapping from tokenid to prices
    mapping(uint => uint) public _price;

    //Mapping to check wether price has been set or not

    mapping(uint=>bool)  internal _isPriceSet; 

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) external view returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner,
            "not authorized"
        );

        _approvals[id] = spender;

        emit Approval(owner, spender, id);
    }

    function getApproved(uint id) external view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint id
    ) internal view returns (bool) {
        return (spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[id]);
    }

    function transferFrom(address from, address to, uint id) public {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint id) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    ""
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id,
        bytes calldata data
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    data
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function _mint(address to, uint id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
}

contract MyNFT is ERC721 {
    ERC20Token public erc20Token;

    constructor(address _ERC20TokenAddress) {
        require(
            _ERC20TokenAddress != address(0),
            "Invalid ERC20 token address"
        );
        erc20Token = ERC20Token(_ERC20TokenAddress);
    }

    function mint(address to, uint id) external {
        _mint(to, id);
    }

      function setPrice(uint256 id, uint256 value) external {
        require(_ownerOf[id] == msg.sender, "Only the owner can set the price");
        _price[id] =  value;
        _isPriceSet[id]=true;
    }

    function exchange(uint id) external {
        address tokenOwner = _ownerOf[id];
        address buyer = msg.sender;
        require(tokenOwner != address(0));
        require(_isPriceSet[id], "Price for the NFT is not set");
        uint buyerBalance = erc20Token.balanceOf(buyer);
        require(buyerBalance >= _price[id]);
        //Transfer tokens from owner's balance
        erc20Token.transferForNFT(tokenOwner, buyer, _price[id]);
        _balanceOf[tokenOwner]--;
        _balanceOf[buyer]++;
        _ownerOf[id] = buyer;
        delete _approvals[id];
        emit Transfer(tokenOwner, buyer, id);
    }

    function burn(uint id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}
