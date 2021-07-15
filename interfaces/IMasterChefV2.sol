pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/IERC20.sol";


interface IMasterChefV2 {

    function pendingSushi(uint256 _pid, address _user) external view
    returns (uint256 pending);
    function sushiPerBlock() external view returns (uint256 amount);
    function deposit(uint256 pid, uint256 amount, address to) external;
    function withdraw(uint256 pid, uint256 amount, address to) external;
    function harvest(uint256 pid, address to) external;
    function withdrawAndHarvest(uint256 pid, uint256 amount, address to) external;
    function harvestFromMasterChef() external;
    function emergencyWithdraw(uint256 pid, address to) external;
    function rewarder(uint256 pid) external view returns (address);
    function userInfo(uint256, address) external view
    returns (uint256 amount, uint256 rewardDebt);
}
