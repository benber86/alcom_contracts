import brownie
import pytest
POOL_ID = 1
PRECISION = 10e-15


@pytest.mark.parametrize("amount", [1, 100, 10**18])
def test_deposit(alice, bob, vault, amount, alcx, alcx_pool, compounder):
    prior_pool_tvl = alcx_pool.getPoolTotalDeposited(POOL_ID)
    prior_alcx_balance = alcx.balanceOf(alice)
    alcx.approve(vault, amount, {'from': alice})
    alcx.approve(vault, amount, {'from': bob})

    vault.deposit(amount, {'from': alice})

    assert vault.balanceOf(alice) == amount
    assert alcx_pool.getPoolTotalDeposited(POOL_ID) == prior_pool_tvl + amount
    assert vault.totalSupply() == amount
    assert alcx.balanceOf(alice) == prior_alcx_balance - amount

    prior_supply = vault.totalSupply()
    vault.deposit(amount, {'from': bob})
    balance = compounder.stakeBalance() - amount

    assert vault.balanceOf(bob) == (amount * prior_supply // (balance))
    assert alcx_pool.getPoolTotalDeposited(POOL_ID) == prior_pool_tvl + amount * 2
    assert vault.totalSupply() == vault.balanceOf(bob) + vault.balanceOf(alice)
    assert alcx_pool.getStakeTotalDeposited(compounder, POOL_ID) == amount * 2


def test_deposit_above_balance(alice, alcx, vault):
    alcx.approve(vault, alcx.balanceOf(alice) + 1, {'from': alice})
    with brownie.reverts():
        vault.deposit(alcx.balanceOf(alice) + 1, {'from': alice})


def test_deposit_zero(alice, alcx, vault):
    alcx.approve(vault, 100, {'from': alice})
    with brownie.reverts():
        vault.deposit(0, {'from': alice})


def test_deposit_non_approved(alice, vault):
    with brownie.reverts():
        vault.deposit(10, {'from': alice})


