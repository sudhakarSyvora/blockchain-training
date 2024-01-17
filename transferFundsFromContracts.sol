// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ContractA {
    address public contractB;
    address public contractD;

    constructor(address _contractB, address _contractD) { 
        contractB = _contractB;
        contractD = _contractD;
    }

    function sendToContractB() external payable {
        require(contractB != address(0), "ContractB address not set");
        (bool success, ) = contractB.call{value: msg.value}("");
        require(success, "Failed to send ETH to ContractB");
    }

    function sendToContractD() external payable {
        require(contractD != address(0), "ContractD address not set");
        (bool success, ) = contractD.call{value: msg.value}("");
        require(success, "Failed to send ETH to ContractD");
    }
     function getContractABalance() external view returns (uint256) {
        return address(this).balance;
    }
     function recieveFunds() public payable {
 
    }

}

contract ContractB {
    address public contractC;

    constructor(address _contractC) {
        contractC = _contractC;
    }

    receive() external payable {
        require(contractC != address(0), "ContractC address not set");
        (bool success, ) = contractC.call{value: msg.value}("");
        require(success, "Failed to send ETH to ContractC");
    }
}

contract ContractC {
    receive() external payable {
      
    }
}


contract ContractD {
    function rejectTransaction() external pure {
        revert("Transaction rejected by ContractD");
    }
      function getContractDBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

