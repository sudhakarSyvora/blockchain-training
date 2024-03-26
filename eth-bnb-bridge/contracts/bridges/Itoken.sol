// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

interface IToken {
  function mint(address to, uint amount) external;
  function burn(address owner, uint amount) external;
}