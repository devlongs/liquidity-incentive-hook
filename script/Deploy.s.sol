// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {MyLiquidityIncentiveHook} from "../src/MyLiquidityIncentiveHook.sol";

contract DeployScript is Script {
    function run() external {

        vm.startBroadcast();

        RewardToken rewardToken = new RewardToken();

        MyLiquidityIncentiveHook hook = new MyLiquidityIncentiveHook(rewardToken);

        vm.stopBroadcast();
    }
}
