// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import './BridgeBase.sol';

contract BridgeEth is BridgeBase {
  constructor(address token) BridgeBase(token) {}
}