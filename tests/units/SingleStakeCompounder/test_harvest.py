import brownie
from brownie import chain
import pytest


@pytest.mark.parametrize("amount", [10**8, 10**12, 10**18])
def test_harvest(alice, bob, vault, amount, alcx, alcx_pool, ss_compounder):

    alcx.approve(vault, 2**256-1, {'from': alice})
    alcx.approve(vault, 2**256-1, {'from': bob})

    vault.deposit(amount, {'from': alice})
    vault.deposit(amount, {'from': bob})

    initial_alcx_balance_bob = alcx.balanceOf(bob)
    initial_pv_alice = vault.getPositionValue.call({'from': alice})
    initial_pv_bob = vault.getPositionValue.call({'from': bob})

    staked_prior = ss_compounder.stakeBalance()
    total_prior = ss_compounder.totalPoolBalance()

    chain.mine(1000)

    assert ss_compounder.totalPoolBalance() > total_prior
    assert ss_compounder.stakeBalance() == staked_prior

    ss_compounder.harvest({'from': bob})

    assert ss_compounder.totalPoolBalance() == ss_compounder.stakeBalance()
    assert ss_compounder.stakeBalance() > staked_prior

    assert alcx_pool.getStakeTotalUnclaimed(ss_compounder, 1) == 0
    assert vault.getPositionValue.call({'from': bob}) > initial_pv_bob
    assert vault.getPositionValue.call({'from': alice}) > initial_pv_alice

    vault.withdrawAll({'from': bob})
    assert alcx.balanceOf(bob) > initial_alcx_balance_bob