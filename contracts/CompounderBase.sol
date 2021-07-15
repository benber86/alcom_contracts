pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IStakingPools.sol";

abstract contract CompounderBase is Ownable {

    using SafeERC20 for IERC20;
    uint256 public poolId;
    // Alchemix Staking Pools contract address
    address public poolContract;
    IStakingPools public Pool;
    // The token that will be staked (ALCX, SLP...)
    IERC20 public Token;
    IERC20 public Vault;
    // Withdrawal fees applied on all exits save the last
    uint256 constant public fee = 250;
    uint256 constant public max = 10000;

    constructor(address _vault,
                address _poolContract,
                uint256 _poolId,
                address token)
    {
        Vault = IERC20(_vault);
        poolContract = _poolContract;
        Pool = IStakingPools(poolContract);
        poolId = _poolId;
        Token = IERC20(token);
    }

    /// @notice Staking function to be overriden
    function stake() public virtual;

    /// @notice Harvesting function to be overriden
    function harvest() external virtual;

    /// @notice Withdraw other ERC-20 tokens received by mistake
    function withdraw(IERC20 _asset) external onlyOwner
    returns (uint256 balance) {
        // Prevents withdrawals of token the contract is meant to stake
        require(_asset != Token);
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
            _withdrawable == Token.balanceOf(address(this));
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
        }
        // Transfer the amount minus the fee back to the vault to be delivered
        // to user
        Token.safeTransfer(address(Vault), _withdrawable);
        return _withdrawable;
    }

    /// @notice Query the amount currently staked
    /// @return total - the total amount of tokens staked
    function stakeBalance() external view returns (uint256 total) {
        uint256 _total = Pool.getStakeTotalDeposited(address(this), poolId);
        return _total;
    }

    /// @notice Query amount currently staked or unclaimed
    /// @return total - the total amount of tokens staked plus claimable
    function totalPoolBalance() external view virtual returns (uint256 total) {
        uint256 _total = Pool.getStakeTotalDeposited(address(this), poolId) +
        Pool.getStakeTotalUnclaimed(address(this), poolId);
        return _total;
    }

}
