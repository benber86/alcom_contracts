pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IStakingPools.sol";

contract Compounder is Ownable {

    using SafeERC20 for IERC20;
    // ALCX single staking pool
    IStakingPools private Pool;
    address public alcxPool;
    uint256 constant public poolId = 1;
    // ALCX token contract address
    address constant public alcxContract = 0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF;
    IERC20 private ALCX = IERC20(alcxContract);
    IERC20 private Vault;
    uint256 constant public fee = 250;
    uint256 constant public max = 10000;

    constructor(address _vault, address _pool){
        Vault = IERC20(_vault);
        alcxPool = _pool;
        Pool = IStakingPools(_pool);
    }

    /// @notice Deposits all ALCX in the contract in the staking pool
    function stake() public {
        ALCX.safeApprove(alcxPool, 0);
        ALCX.safeApprove(alcxPool, ALCX.balanceOf(address(this)));
        Pool.deposit(poolId, ALCX.balanceOf(address(this)));
    }

    /// @notice Claims rewards from the pool and restakes them
    function harvest() external {
        Pool.claim(poolId);
        stake();
    }

    /// @notice Withdraw non-ALCX ERC-20 tokens received by mistake
    function withdraw(IERC20 _asset) external onlyOwner
    returns (uint256 balance) {
        // Prevents ALCX withdrawals
        require(_asset != ALCX);
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(msg.sender, balance);
    }

    /// @notice Withdraw partial funds, called from the Vault
    /// @param _amount - the amount to withdraw
    /// @return withdrawable - the amount to withdraw minus withdrawal fee
    function withdraw(uint256 _amount) external
    returns (uint256 withdrawable){
        // Only the vault can withdraw
        require(msg.sender == address(Vault), "!vault");

        uint256 _withdrawable = _amount;
        // If user is last to withdraw, we exit the pool
        if (Vault.totalSupply() == 0) {
            Pool.exit(poolId);
            _withdrawable == ALCX.balanceOf(address(this));
        }
        else {
            // We substract a small 0.25% withdrawal fee to prevent users "timing"
            // the harvests. The fee stays staked and so is effectively
            // redistributed to all remaining participants.
            uint256 _fee = _amount * fee / max;
            _withdrawable = _withdrawable - _fee;
            // Withdraw the rest. Note that this will also claim rewards.
            // The rewards will remain in the contract until the next deposit or
            // harvest.
            Pool.withdraw(poolId, _withdrawable);
            // Transfer the amount minus the fee back to the vault to be delivered
            // to user.
        }
        ALCX.safeTransfer(address(Vault), _withdrawable);
        return _withdrawable;
    }

    /// @notice Query the amount currently staked
    /// @return total - the total amount of ALCX staked
    function stakeBalance() external view returns (uint256 total) {
        uint256 _total = Pool.getStakeTotalDeposited(address(this), poolId);
        return _total;
    }

    /// @notice Query amount currently staked or unclaimed
    /// @return total - the total amount of ALCX staked and claimable
    function totalPoolBalance() external view returns (uint256 total) {
        uint256 _total = Pool.getStakeTotalDeposited(address(this), poolId) +
        Pool.getStakeTotalUnclaimed(address(this), poolId);
        return _total;
    }

}
