// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ImplementationContract {
    bool private isInitialized;

    function initializer() external {
        require(!isInitialized, "Contract already initialized");
        isInitialized = true;
    }

}
