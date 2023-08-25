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

Run [SMTChecker](https://docs.soliditylang.org/en/v0.8.21/smtchecker.html) with `solc` (only works on Linux or WSL for now):

1. Install [`z3`](https://github.com/Z3Prover/z3):

```
sudo apt install z3
```

2. Run SMTChecker:

```
solc ./test/SMTChecker.sol --model-checker-engine all
```
