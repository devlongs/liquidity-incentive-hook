// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/RewardToken.sol";
import "../src/MyLiquidityIncentiveHook.sol";
import { IPoolManager } from "v4-core/src/interfaces/IPoolManager.sol";
import { PoolKey, ModifyPositionParams } from "v4-core/src/interfaces/IPoolManager.sol";

/**
 * @title MyLiquidityIncentiveHookTest
 */
contract MyLiquidityIncentiveHookTest is Test {
    RewardToken rewardToken;
    MyLiquidityIncentiveHook hook;

    address user = address(0xABCD);

    function setUp() public {
        rewardToken = new RewardToken();
        hook = new MyLiquidityIncentiveHook(rewardToken);
    }

    function testAccumulateRewards() public {
        IPoolManager.PoolKey memory poolKey = IPoolManager.PoolKey({
            token0: address(0x1111),
            token1: address(0x2222),
            fee: 3000,
            tickSpacing: 60,
            hook: address(hook)
        });

        ModifyPositionParams memory addParams = ModifyPositionParams({
            owner: user,
            tickLower: -60000,
            tickUpper: 60000,
            amount0: 0,
            amount1: 0,
            deltaLiquidity: 1000
        });

        vm.prank(user);
        hook.beforeModifyPosition(user, poolKey, addParams, "");

        vm.prank(user);
        hook.afterModifyPosition(user, poolKey, addParams, addParams, "");

        vm.warp(block.timestamp + 3600);

        ModifyPositionParams memory removeParams = ModifyPositionParams({
            owner: user,
            tickLower: -60000,
            tickUpper: 60000,
            amount0: 0,
            amount1: 0,
            deltaLiquidity: -500
        });

        vm.prank(user);
        hook.beforeModifyPosition(user, poolKey, removeParams, "");

        vm.prank(user);
        hook.afterModifyPosition(user, poolKey, removeParams, removeParams, "");

        uint256 userBalance = rewardToken.balanceOf(user);
        emit log_named_uint("User reward token balance:", userBalance);

        assertTrue(userBalance > 0, "Expected user to have > 0 rewards");
    }
}
