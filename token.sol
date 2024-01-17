// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract tokenContract {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(uint256 totalSupplyValue) {
        _totalSupply = totalSupplyValue;
        _balances[msg.sender] = totalSupplyValue;
    }

    function name() public pure returns (string memory) {
        return "lafucaDecosta";
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_balances[msg.sender] >= _value && _to != address(0));
        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            _from != address(0) &&
                _to != address(0) &&
                _allowed[_from][msg.sender] >= _value &&
                _balances[_from] >= _value
        );
        _allowed[_from][msg.sender] -= _value;
        _balances[_to] += _value;
        _balances[_from] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        require(_spender != address(0));
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        require(_owner != address(0) && _spender != address(0));
        return _allowed[_owner][_spender];
    }
}
