pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
// https://github.com/alchemix-finance/alchemix-protocol/blob/master/contracts/StakingPools.sol

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/IERC20.sol";


interface IStakingPools {

    function tokenPoolIds(address token) external returns (uint256 poolId);
    function deposit(uint256 _poolId, uint256 _depositAmount) external;
    function withdraw(uint256 _poolId, uint256 _withdrawAmount) external;
    function claim(uint256 _poolId) external;
    function exit(uint256 _poolId) external;
    function rewardRate() external view returns (uint256);
    function totalRewardWeight() external view returns (uint256);
    function poolCount() external view returns (uint256);
    function getPoolToken(uint256 _poolId) external view returns (IERC20);
    function getPoolTotalDeposited(uint256 _poolId) external view returns (uint256);
    function getPoolRewardWeight(uint256 _poolId) external view returns (uint256);
    function getPoolRewardRate(uint256 _poolId) external view returns (uint256);
    function getStakeTotalDeposited(address _account, uint256 _poolId) external view returns (uint256);
    function getStakeTotalUnclaimed(address _account, uint256 _poolId) external view returns (uint256);
}
