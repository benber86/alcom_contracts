pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../interfaces/IStakingPools.sol";

contract MockPool is IStakingPools {

    using SafeERC20 for IERC20;
    IERC20 public token;

    constructor(IERC20 _token){
        token = _token;
    }

    function deposit(uint256 _poolId, uint256 _depositAmount)
    external override {
        token.safeTransferFrom(msg.sender, address(this), _depositAmount);
    }

    function withdraw(uint256 _poolId, uint256 _withdrawAmount)
    external override {
        token.safeTransfer(msg.sender, _withdrawAmount);
    }
    function exit(uint256 _poolId) external override {
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function getStakeTotalDeposited(address _account, uint256 _poolId)
    external view override returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getStakeTotalUnclaimed(address _account, uint256 _poolId)
    external view override returns (uint256) {
        return 0;
    }

    function getPoolTotalDeposited(uint256 _poolId)
    external view override returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getPoolRewardWeight(uint256 _poolId)
    external view override returns (uint256) {
        return 0;
    }

    function getPoolRewardRate(uint256 _poolId)
    external view override returns (uint256) {
        return 0;
    }

    function getPoolToken(uint256 _poolId)
    external view override returns (IERC20) {
        return token;
    }

    function poolCount()
    external view override returns (uint256) {
        return 1;
    }

    function totalRewardWeight()
    external view override returns (uint256) {
        return 0;
    }
    function rewardRate()
    external view override returns (uint256) {
        return 0;
    }

    function tokenPoolIds(address token)
    external override returns (uint256 poolId) {
        return 0;
    }

    function claim(uint256 _poolId) external override {}


}
