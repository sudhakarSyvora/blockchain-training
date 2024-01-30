// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;
import "./IERC20.sol";

contract ERC20Token is IERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;
    address private _contractOwner;

    constructor(
        uint256 totalSupplyValue,
        string memory nameValue,
        uint8 decimalsValue,
        string memory symbolValue
    ) {
        _totalSupply = totalSupplyValue;
        _balances[msg.sender] = totalSupplyValue;
        name = nameValue;
        decimals = decimalsValue;
        symbol = symbolValue;
        _contractOwner = msg.sender;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return _balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(
            _balances[msg.sender] >= _value && _to != address(0),
            "ERC20: Insufficient balance"
        );
        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(
            _from != address(0) &&
                _to != address(0) &&
                _allowed[_from][msg.sender] >= _value &&
                _balances[_from] >= _value,
            "Not approved"
        );
        _allowed[_from][msg.sender] -= _value;
        _balances[_to] += _value;
        _balances[_from] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success) {
        require(_spender != address(0));
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining) {
        require(_owner != address(0) && _spender != address(0));
        return _allowed[_owner][_spender];
    }

    function mint(address _to,uint256 _value) external  returns (bool success) {
        require(msg.sender == _contractOwner, "Owner can only mint new tokens");
        _totalSupply = _totalSupply + _value;
        _balances[_to] = _balances[_to] + _value;
        return true;
    }
}
