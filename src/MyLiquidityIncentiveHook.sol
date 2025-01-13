// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import { IHooks } from "v4-core/src/interfaces/IHooks.sol";
import { IPoolManager } from "v4-core/src/interfaces/IPoolManager.sol";
import { RewardToken } from "./RewardToken.sol";
import "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title MyLiquidityIncentiveHook
 * @notice Example time-based LP incentive Hook for Uniswap v4.
 */
contract MyLiquidityIncentiveHook is IHooks, Ownable {
    struct PositionInfo {
        uint128 liquidity;
        uint256 lastUpdated;
        uint256 accumulatedRewards;
    }

    mapping(bytes32 => PositionInfo) public positions;
    RewardToken public immutable rewardToken;

    uint256 public rewardRate = 1e14;

    constructor(RewardToken _rewardToken) {
        rewardToken = _rewardToken;
    }

    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
    }

    function _makePositionKey(
        IPoolManager.PoolKey calldata poolKey,
        address owner,
        int24 tickLower,
        int24 tickUpper
    ) internal pure returns (bytes32) {
        bytes32 keyHash = keccak256(abi.encode(poolKey));
        return keccak256(abi.encode(keyHash, owner, tickLower, tickUpper));
    }

    function _updatePositionRewards(bytes32 posKey) internal {
        PositionInfo storage pos = positions[posKey];
        if (pos.liquidity > 0) {
            uint256 delta = block.timestamp - pos.lastUpdated;
            pos.accumulatedRewards += delta * pos.liquidity * rewardRate;
        }
        pos.lastUpdated = block.timestamp;
    }

    function _claimRewards(bytes32 posKey, address to) internal {
        PositionInfo storage pos = positions[posKey];
        uint256 owed = pos.accumulatedRewards;
        if (owed > 0) {
            pos.accumulatedRewards = 0;
            rewardToken.mint(to, owed);
        }
    }

    function beforeInitialize(
        address,
        IPoolManager.PoolKey calldata,
        function(IPoolManager.PoolKey calldata) external returns (uint160, int24),
        bytes calldata
    ) external returns (bytes4) {
        return IHooks.beforeInitialize.selector;
    }

    function afterInitialize(
        address,
        IPoolManager.PoolKey calldata,
        uint160,
        int24,
        bytes calldata
    ) external returns (bytes4) {
        return IHooks.afterInitialize.selector;
    }

    function beforeModifyPosition(
        address,
        IPoolManager.PoolKey calldata poolKey,
        IPoolManager.ModifyPositionParams calldata params,
        bytes calldata
    ) external returns (bytes4) {
        bytes32 posKey = _makePositionKey(poolKey, params.owner, params.tickLower, params.tickUpper);
        _updatePositionRewards(posKey);

        return IHooks.beforeModifyPosition.selector;
    }

    function afterModifyPosition(
        address,
        IPoolManager.PoolKey calldata poolKey,
        IPoolManager.ModifyPositionParams calldata params,
        IPoolManager.ModifyPositionParams memory result,
        bytes calldata
    ) external returns (bytes4) {
        bytes32 posKey = _makePositionKey(poolKey, params.owner, params.tickLower, params.tickUpper);

        if (params.deltaLiquidity > 0) {
            positions[posKey].liquidity += uint128(params.deltaLiquidity);
        } else if (params.deltaLiquidity < 0) {
            uint128 absDelta = uint128(-params.deltaLiquidity);
            require(positions[posKey].liquidity >= absDelta, "Not enough liquidity");
            positions[posKey].liquidity -= absDelta;

            _claimRewards(posKey, params.owner);
        }

        positions[posKey].lastUpdated = block.timestamp;
        return IHooks.afterModifyPosition.selector;
    }

    function beforeSwap(
        address,
        IPoolManager.PoolKey calldata,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external returns (bytes4) {
        return IHooks.beforeSwap.selector;
    }

    function afterSwap(
        address,
        IPoolManager.PoolKey calldata,
        IPoolManager.SwapParams calldata,
        int256,
        int256,
        bytes calldata
    ) external returns (bytes4) {
        return IHooks.afterSwap.selector;
    }

    function beforeDonate(
        address,
        IPoolManager.PoolKey calldata,
        uint256,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        return IHooks.beforeDonate.selector;
    }

    function afterDonate(
        address,
        IPoolManager.PoolKey calldata,
        uint256,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        return IHooks.afterDonate.selector;
    }


    function hooks() external pure returns (Hooks) {
        return Hooks.BEFORE_INITIALIZE |
               Hooks.AFTER_INITIALIZE  |
               Hooks.BEFORE_MODIFY_POSITION |
               Hooks.AFTER_MODIFY_POSITION  |
               Hooks.BEFORE_SWAP |
               Hooks.AFTER_SWAP  |
               Hooks.BEFORE_DONATE |
               Hooks.AFTER_DONATE;
    }
}
