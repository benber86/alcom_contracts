pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IStakingPools.sol";
import "./CompounderBase.sol";

contract SingleStakeCompounder is CompounderBase {

    using SafeERC20 for IERC20;
    address constant public ALCX = 0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF;

    constructor(address _vault,
        address _poolContract)
        public CompounderBase(
        _vault,
        _poolContract,
        1,
        ALCX
    ) {}


    /// @notice Deposits all ALCX in the contract in the staking pool
    function stake() public override {
        Token.safeApprove(poolContract, 0);
        Token.safeApprove(poolContract, Token.balanceOf(address(this)));
        Pool.deposit(poolId, Token.balanceOf(address(this)));
    }

    /// @notice Claims rewards from the pool and restakes them
    function harvest() external override {
        Pool.claim(poolId);
        stake();
    }

}
