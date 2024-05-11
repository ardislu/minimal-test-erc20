// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

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

  // transferFrom() updates balances and allowance as expected and does not modify totalSupply
  function transferFromUpdatesBalances(address randFrom, address randTo, uint256 amount) public {
    // Preconditions:
    require(address(this) != randFrom);
    require(address(this) != randTo);
    require(randFrom != randTo);
    require(this.totalSupply() == amount);
    require(this.balanceOf(randFrom) == amount);
    require(this.balanceOf(randTo) == 0);
    require(this.allowance(randFrom, address(this)) == amount);

    // Action:
    this.transferFrom(randFrom, randTo, amount);

    // Postconditions:
    assert(this.totalSupply() == amount);
    assert(this.balanceOf(randFrom) == 0);
    assert(this.balanceOf(randTo) == amount);
    assert(this.allowance(randFrom, address(this)) == 0);
  }
}
