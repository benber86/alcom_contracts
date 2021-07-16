pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
// Based on https://github.com/yearn/vaults/blob/master/contracts/vaults/yVault.sol

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/access/Ownable.sol";
import "../interfaces/ICompounder.sol";

contract Vault is ERC20, Ownable {

    using SafeERC20 for IERC20;
    // Compounder contract
    address public compounderContract = address(0);
    ICompounder public Compounder;
    // Contract address of the token to stake
    address public tokenContract;
    IERC20 public StakeToken;

    constructor (address _token) public ERC20(
        string(abi.encodePacked("alcom ", ERC20(_token).name())),
        string(abi.encodePacked("alc", ERC20(_token).symbol())))
    {
        tokenContract = _token;
        StakeToken = IERC20(tokenContract);

    }

    /// @notice Set the address of the autocompounding contract
    /// @dev Can only be set once
    /// @param _compounderContract - address of the autocompounding contract
    function setCompounder(address _compounderContract)
    external onlyOwner {
        require(compounderContract == address(0), "Compounder already set");
        compounderContract = _compounderContract;
        Compounder = ICompounder(compounderContract);
    }


    /// @notice Deposit user funds in the autocompounder and mints tokens
    ///         representing user's share of the pool in exchange
    /// @param _amount - the amount of tokens to deposit
    function deposit(uint256 _amount) public autoCompounderSet {
        require(_amount != 0, "Deposit too small");
        uint256 _before = Compounder.stakeBalance();
        StakeToken.safeTransferFrom(msg.sender, compounderContract, _amount);
        Compounder.stake();

        // Issues shares in proportion of deposit to pool amount
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = _amount * totalSupply() / _before;
        }
        _mint(msg.sender, shares);
    }

    /// @notice Deposit all of user's token balance
    function depositAll() external {
        deposit(StakeToken.balanceOf(msg.sender));
    }

    /// @notice Withdraws user's ALCX from the pool in proportion to the amount
    ///         of share tokens sent
    /// @param _shares - the number of ssALCX to send
    function withdraw(uint _shares) public {
        require(totalSupply() > 0);
        // Computes the amount of ALCX withdrawable from the compounder based on
        // the number of shares sent
        uint256 amount = _shares * Compounder.stakeBalance()
        / totalSupply();
        // Burn the shares before retrieving tokens
        _burn(msg.sender, _shares);
        // Withdraw from the compounder
        uint256 _withdrawable = Compounder.withdraw(amount);
        // And sends back tokens to user
        StakeToken.safeTransfer(msg.sender, _withdrawable);
    }

    /// @notice Withdraw all of a users' position
    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }

    /// @notice Gives the ALCX value of a user's amount of ssALCX
    /// @return the ALCX value
    function getPositionValue() external view
    returns (uint256) {
        if (totalSupply() > 0) {
        return (balanceOf(msg.sender) * Compounder.stakeBalance()
        / totalSupply());
        }
        else return 0;
    }

    modifier autoCompounderSet() {
        require(
            compounderContract != address(0),
            "Compounder not set");
        _;
    }
}
