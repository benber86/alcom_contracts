pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IStakingPools.sol";
import "./CompounderBase.sol";

contract SingleStakeCompounder is CompounderBase {

    using SafeERC20 for IERC20;
    address constant public alcx = 0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF;

    constructor(address _vault,
        address _poolContract)
        public CompounderBase(
        _vault,
        _poolContract, // 0xAB8e74017a8Cc7c15FFcCd726603790d26d7DeCa
        1,
        alcx
    ) {}


    /// @notice Deposits all ALCX in the contract in the staking pool
    function stake() public override {
        token.safeApprove(poolContract, 0);
        token.safeApprove(poolContract, token.balanceOf(address(this)));
        pool.deposit(poolId, token.balanceOf(address(this)));
    }

    /// @notice Claims rewards from the pool and restakes them
    function harvest() external override {
        pool.claim(poolId);
        stake();
    }

}
