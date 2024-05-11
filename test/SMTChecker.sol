// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import '../ERC20.sol';

contract SMTChecker is ERC20 {
  // It's impossible to set totalSupply without debugging tools
  function totalSupplyIsZero() public view {
    assert(this.totalSupply() == 0);
  }

  // It's impossible to set balanceOf without debugging tools
  function balanceOfIsZero(address rand) public view {
    assert(this.balanceOf(rand) == 0);
  }

  // transfer() updates balances as expected and does not modify totalSupply
  function transferUpdatesBalances(address rand, uint256 amount) public {
    // Preconditions:
    require(address(this) != rand);
    require(this.totalSupply() == amount);
    require(this.balanceOf(address(this)) == amount);
    require(this.balanceOf(rand) == 0);

    // Action:
    this.transfer(rand, amount);

    // Postconditions:
    assert(this.totalSupply() == amount);
    assert(this.balanceOf(address(this)) == 0);
    assert(this.balanceOf(rand) == amount);
  }
}
