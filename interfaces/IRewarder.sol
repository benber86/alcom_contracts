pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
    function onSushiReward(uint256 pid, address user, address recipient,
        uint256 sushiAmount, uint256 newLpAmount) external;
    function pendingToken(uint256 pid, address user)
    external view returns (uint256);
}