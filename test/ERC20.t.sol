// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import '../ERC20.sol';

// See documentation for more details and usage examples:
// https://github.com/foundry-rs/foundry/tree/master/crates/forge
interface Vm {
  function deal(address recipient, uint256 amount) external;
  function store(address contractAddr, bytes32 slot, bytes32 value) external;
  function prank(address sender) external;
  function startPrank(address sender) external;
  function stopPrank() external;
  function assume(bool) external;
  function expectRevert() external;
}

contract TestERC20 {
  address constant u1 = address(1);
  address constant u2 = address(2);
  address constant u3 = address(3);

  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
  ERC20 token;

  function setUp() public {
    token = new ERC20();

    // Give 100 ETH to all test users
    vm.deal(u1, 100 ether);
    vm.deal(u2, 100 ether);
    vm.deal(u3, 100 ether);

    // Give 100 ERC20 to all test users
    vm.store(address(token), keccak256(abi.encodePacked(uint256(uint160(u1)), uint256(1))), bytes32(uint256(100 ether)));
    vm.store(address(token), keccak256(abi.encodePacked(uint256(uint160(u2)), uint256(1))), bytes32(uint256(100 ether)));
    vm.store(address(token), keccak256(abi.encodePacked(uint256(uint160(u3)), uint256(1))), bytes32(uint256(100 ether)));

    // Set totalSupply
    vm.store(address(token), 0, bytes32(uint256(100 ether * 3)));
  }

  // Validate that setUp() works
  function testSetUp() public view {
    assert(u1.balance == 100 ether);
    assert(u2.balance == 100 ether);
    assert(u3.balance == 100 ether);
    assert(token.balanceOf(u1) == 100 ether);
    assert(token.balanceOf(u2) == 100 ether);
    assert(token.balanceOf(u3) == 100 ether);
    assert(token.totalSupply() == 100 ether * 3);
  }

  // transfer() should update balances as expected
  function testTransfer(uint256 rand, address recipient) public {
    // Precondition:
    vm.assume(recipient != u1 && recipient != u2 && recipient != u3);
    uint256 initialU1Balance = token.balanceOf(u1);
    uint256 value = rand % initialU1Balance;

    // Action:
    vm.prank(u1);
    bool success = token.transfer(recipient, value);

    // Postcondition:
    uint256 finalU1Balance = token.balanceOf(u1);
    uint256 finalRecipientBalance = token.balanceOf(recipient);
    assert(success);
    assert(finalU1Balance == initialU1Balance - value);
    assert(finalRecipientBalance == value);
  }

  // transferFrom() should update balances as expected
  function testTransferFrom(uint256 rand, address sender, address recipient) public {
    // Precondition:
    vm.assume(sender != u1 && sender != u2 && sender != u3
      && recipient != u1 && recipient != u2 && recipient != u3
      && sender != recipient);
    uint256 initialU1Balance = token.balanceOf(u1);
    uint256 value = rand % initialU1Balance;

    // Action:
    vm.prank(u1);
    bool approveSuccess = token.approve(sender, value);
    vm.prank(sender);
    bool transferSuccess = token.transferFrom(u1, recipient, value);
    
    // Postcondition:
    uint256 finalU1Balance = token.balanceOf(u1);
    uint256 finalSenderBalance = token.balanceOf(sender);
    uint256 finalSenderAllowance = token.allowance(u1, sender);
    uint256 finalRecipientBalance = token.balanceOf(recipient);
    assert(approveSuccess);
    assert(transferSuccess);
    assert(finalU1Balance == initialU1Balance - value);
    assert(finalSenderBalance == 0);
    assert(finalSenderAllowance == 0);
    assert(finalRecipientBalance == value);
  }

  // approve() should update allowance as expected
  function testApprove(uint256 rand, address target) public {
    // Precondition:
    vm.assume(target != u1);
    uint256 initialAllowance = token.allowance(u1, target);
    uint256 value = rand % token.balanceOf(u1);

    // Action:
    vm.prank(u1);
    bool approveSuccess = token.approve(target, value);

    // Postcondition:
    uint256 finalAllowance = token.allowance(u1, target);
    assert(approveSuccess);
    assert(finalAllowance == initialAllowance + value);
  }

  // Transferring to self using transfer() should have no effect
  function testSelfTransfer(uint256 rand) public {
    // Precondition:
    uint256 initialBalance = token.balanceOf(u1);
    uint256 value = rand % initialBalance;

    // Action:
    vm.prank(u1);
    bool success = token.transfer(u1, value);

    // Postcondition:
    uint256 finalBalance = token.balanceOf(u1);
    assert(success);
    assert(initialBalance == finalBalance);
  }

  // Transferring to self using transferFrom() should have no effect
  function testSelfTransferFrom(uint256 rand) public {
    // Precondition:
    uint256 initialBalance = token.balanceOf(u1);
    uint256 value = rand % initialBalance;

    // Action:
    vm.startPrank(u1);
    bool approveSuccess = token.approve(u1, value);
    bool transferSuccess = token.transferFrom(u1, u1, value);
    vm.stopPrank();

    // Postcondition:
    uint256 finalBalance = token.balanceOf(u1);
    assert(approveSuccess);
    assert(transferSuccess);
    assert(initialBalance == finalBalance);
  }

  // Transferring 0 tokens using transfer() should have no effect
  function testZeroTransfer(address rand) public {
    // Precondition:
    vm.assume(rand != u1 && rand != u2 && rand != u3);
    uint256 initialU1Balance = token.balanceOf(u1);

    // Action:
    vm.prank(u1);
    bool success = token.transfer(rand, 0);

    // Postcondition:
    uint256 finalU1Balance = token.balanceOf(u1);
    uint256 finalRandBalance = token.balanceOf(rand);
    assert(success);
    assert(initialU1Balance == finalU1Balance);
    assert(finalRandBalance == 0);
  }
  
  // Transferring 0 tokens using transferFrom() should have no effect
  function testZeroTransferFrom(address rand) public {
    // Precondition:
    vm.assume(rand != u1 && rand != u2 && rand != u3);
    uint256 initialU1Balance = token.balanceOf(u1);

    // Action:
    vm.startPrank(u1);
    bool approveSuccess = token.approve(u1, 0);
    bool transferSuccess = token.transferFrom(u1, rand, 0);
    vm.stopPrank();

    // Postcondition:
    uint256 finalU1Balance = token.balanceOf(u1);
    uint256 finalRandBalance = token.balanceOf(rand);
    assert(approveSuccess);
    assert(transferSuccess);
    assert(initialU1Balance == finalU1Balance);
    assert(finalRandBalance == 0);
  }

  // Invalid transfer() and transferFrom() calls should revert
  function testInvalidTransfer(uint256 rand, address target) public {
    // Precondition:
    vm.assume(target != u1 && target != u2 && target != u3);
    uint256 initialU1Balance = token.balanceOf(u1);
    vm.assume(rand > 0 && rand < type(uint256).max - initialU1Balance);
    uint256 value = initialU1Balance + rand; // Random value above initialU1Balance, but not causing overflow

    // Action:
    vm.startPrank(u1);

    // Transferring more than balance should revert
    vm.expectRevert();
    token.transfer(target, value);

    token.approve(u1, value);
    vm.expectRevert();
    token.transferFrom(u1, target, value);

    vm.stopPrank();
  }
}
