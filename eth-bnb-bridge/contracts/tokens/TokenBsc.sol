// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import './TokenBase.sol';

contract TokenBsc is TokenBase {
  constructor() TokenBase('BSC Token', 'BTK') {}
}