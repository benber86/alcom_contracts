pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
// Based on: https://github.com/pickle-finance/protocol/blob/fa4cd294d45795cc776d3c123226aba7447c85dd/src/strategies/alchemix/strategy-alcx-farm-base.sol

import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IRewarder.sol";
import "../interfaces/IMasterChefV2.sol";
import "../interfaces/IUniswapV2Router02.sol";
import "./CompounderBase.sol";

contract SLPCompounder is Ownable {

    using SafeERC20 for IERC20;
    // SLP Token address
    address constant public slp = 0xC3f279090a47e80990Fe3a9c30d24Cb117EF91a8;
    // The token that will be staked
    IERC20 public token = IERC20(slp);
    // Sushi contract & token
    address constant public sushiContract =
    0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    IERC20 public sushi = IERC20(sushiContract);
    // ALCX contract &token
    address constant public alcxContract =
    0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF;
    IERC20 public alcx = IERC20(alcxContract);
    // WETH
    address public constant wethContract =
    0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IERC20 public weth = IERC20(wethContract);
    // Sushi (UniswapV2) Router
    address constant public sushiRouterContract =
    0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    IUniswapV2Router02 sushiRouter = IUniswapV2Router02(sushiRouterContract);
    // Vault
    IERC20 public vault;
    // Masterchef contract
    address public masterChefContract;
    // Masterchef poolId
    uint256 public poolId = 0;
    IMasterChefV2 public masterChef;

    // Withdrawal fees applied on all exits save the last
    uint256 constant public fee = 250;
    uint256 constant public max = 10000;

    constructor(address _vault,
        address _poolContract)  {
        vault = IERC20(_vault);
        masterChefContract = _poolContract;
        // 0xEF0881eC094552b2e128Cf945EF17a6752B4Ec5d
        masterChef = IMasterChefV2(masterChefContract);
    }


    /// @notice Deposits all ALCX in the contract in the staking pool
    function stake() public {
        token.safeApprove(masterChefContract, 0);
        token.safeApprove(masterChefContract, token.balanceOf(address(this)));
        masterChef.deposit(poolId,
            token.balanceOf(address(this)), address(this));
    }

    /// @notice Claims rewards from the pool and restakes them
    function harvest() external {
        masterChef.harvest(poolId, address(this));

        uint256 _alcxAmount = alcx.balanceOf(address(this));
        if (_alcxAmount > 0) {
            uint256 _amount = _alcxAmount / 2;
            alcx.safeApprove(sushiRouterContract, 0);
            alcx.safeApprove(sushiRouterContract, _amount);
            _swap(alcxContract, wethContract, _amount);
        }

        uint256 _sushiAmount = IERC20(sushi).balanceOf(address(this));
        if (_sushiAmount > 0) {
            uint256 _amount = _sushiAmount / 2;
            sushi.safeApprove(sushiRouterContract, 0);
            sushi.safeApprove(sushiRouterContract, _sushiAmount);
            _swap(sushiContract, wethContract, _amount);
            _swap(sushiContract, alcxContract, _amount);
        }

        uint256 _wethAmount = weth.balanceOf(address(this));
        _alcxAmount = IERC20(alcx).balanceOf(address(this));


        if (_wethAmount > 0 && _alcxAmount > 0) {
            weth.safeApprove(sushiRouterContract, 0);
            weth.safeApprove(sushiRouterContract, _wethAmount);

            alcx.safeApprove(sushiRouterContract, 0);
            alcx.safeApprove(sushiRouterContract, _alcxAmount);

            sushiRouter.addLiquidity(
                wethContract,
                alcxContract,
                _wethAmount,
                _alcxAmount,
                0,
                0,
                address(this),
                block.timestamp + 60
            );

            // Transfers dust to caller
            weth.transfer(
                msg.sender,
                weth.balanceOf(address(this))
            );
            alcx.safeTransfer(
                msg.sender,
                alcx.balanceOf(address(this))
            );
        }

        stake();
    }

    /// @notice Withdraw other ERC-20 tokens received by mistake
    function withdraw(IERC20 _asset) external onlyOwner
    returns (uint256 balance) {
        // Prevents withdrawals of token the contract is meant to stake
        require(_asset != token);
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(msg.sender, balance);
    }

    /// @notice Query the amount currently staked
    /// @return total - the total amount of tokens staked
    function stakeBalance() public view returns (uint256 total) {
        (uint256 _total, ) = masterChef.userInfo(poolId, address(this));
        return _total;
    }

    /// @notice Query amount currently staked or unclaimed
    /// @dev Ignores the sushi rewards
    /// @return total - the total amount of tokens staked plus claimable
    function totalPoolBalance() external view returns (uint256 total) {
        uint256 _total = stakeBalance() + getHarvestableAlcx();
        return _total;
    }

    /// @notice Query the amount of harvestable sushi
    function getHarvestableSushi() public view returns (uint256) {
        return masterChef.pendingSushi(poolId, address(this));
    }

    /// @notice Query the amount of harvestable alcx
    function getHarvestableAlcx() public view returns (uint256) {
        address rewarder = masterChef.rewarder(poolId);
        return IRewarder(rewarder).pendingToken(poolId, address(this));
    }

    function _swap(address _from, address _to, uint256 _amount) internal {
        require(_to != address(0));

        address[] memory path;

        if (_from == wethContract || _to == wethContract) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = wethContract;
            path[2] = _to;
        }

        sushiRouter.swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            block.timestamp + 60
        );
    }
}