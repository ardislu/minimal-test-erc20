# minimal-test-erc20

This is a minimal ERC-20 implementation intended to be copied into test cases for other smart contracts.

Run static analysis using [`slither`](https://github.com/crytic/slither):

```
slither ./ERC20.sol
```

Fuzz using [`forge`](https://github.com/foundry-rs/foundry/tree/master/crates/forge):

```
forge test
```
