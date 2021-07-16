import brownie
from brownie import chain
import pytest


def test_harvest(sushi_lper1, sushi_lper2, slp_vault, slp, slp_compounder):

    amount = 10**18
    slp.approve(slp_vault, 2**256-1, {'from': sushi_lper1})
    slp.approve(slp_vault, 2**256-1, {'from': sushi_lper2})

    slp_vault.deposit(amount, {'from': sushi_lper1})
    slp_vault.deposit(amount, {'from': sushi_lper2})

    initial_alcx_balance_sushi_lper2 = slp.balanceOf(sushi_lper2)
    initial_pv_sushi_lper1 = slp_vault.getPositionValue.call({'from': sushi_lper1})
    initial_pv_sushi_lper2 = slp_vault.getPositionValue.call({'from': sushi_lper2})

    staked_prior = slp_compounder.stakeBalance()
    total_prior = slp_compounder.totalPoolBalance()

    chain.mine(1000)

    assert slp_compounder.totalPoolBalance() > total_prior
    assert slp_compounder.stakeBalance() == staked_prior

    slp_compounder.harvest({'from': sushi_lper2})

    assert slp_compounder.totalPoolBalance() == slp_compounder.stakeBalance()
    assert slp_compounder.stakeBalance() > staked_prior
    assert slp_compounder.getHarvestableSushi() == 0

    assert slp_vault.getPositionValue.call({'from': sushi_lper2}) > initial_pv_sushi_lper2
    assert slp_vault.getPositionValue.call({'from': sushi_lper1}) > initial_pv_sushi_lper1

    slp_vault.withdrawAll({'from': sushi_lper2})
    assert slp.balanceOf(sushi_lper2) > initial_alcx_balance_sushi_lper2