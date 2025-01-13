# Uniswap V4 Liquidity Incentive Hook (Foundry)

This repository demonstrates a **time-based liquidity incentive** for [Uniswap v4](https://github.com/Uniswap/v4-core) using [Foundry](https://book.getfoundry.sh/). It includes:

1. **Reward Token**: An ERC-20 token to distribute as rewards.
2. **Custom Hook**: A contract that implements the Uniswap v4 `IHooks` interface, tracking liquidity positions and minting rewards for LPs over time.
3. **Foundry Scripts**: For deployment and testing.

## Features

- **Time-based rewards**: Liquidity providers earn tokens proportional to how long they keep their liquidity in the pool.
- **Basic deployment**: Includes a Foundry `Deploy.s.sol` script to easily deploy the reward token and hook.
- **Unit tests**: Shows how to unit test Uniswap v4 hook callbacks by simulating `beforeModifyPosition` and `afterModifyPosition` calls.


