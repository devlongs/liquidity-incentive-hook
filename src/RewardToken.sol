// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title RewardToken
 * @dev Simple ERC20 used to reward liquidity providers.
 */
contract RewardToken is ERC20, Ownable {
    constructor() ERC20("Liquidity Reward Token", "LRT") {
        _mint(msg.sender, 1_000_000 ether);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
