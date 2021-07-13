pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/IERC20.sol";

interface ICompounder {
    function stakeBalance() external view returns (uint256);
    function totalPoolBalance() external view returns (uint256);
    function withdraw(uint256 _amount) external returns (uint256);
    function withdraw(IERC20 _asset) external;
    function stake() external;
    function harvest() external;
}
