import brownie
import pytest
import math


@pytest.mark.parametrize("amount", [1, 100, 10**18])
def test_mutiple_withdraw_mock(amount, alice, bob, charlie, dave, mock_vault, alcx, mock_ss_compounder):

    prior_alcx_balance_alice = alcx.balanceOf(alice)
    prior_alcx_balance_bob = alcx.balanceOf(bob)
    prior_alcx_balance_charlie = alcx.balanceOf(charlie)
    prior_alcx_balance_dave = alcx.balanceOf(dave)
    for account in [alice, bob, charlie, dave]:
        alcx.approve(mock_vault, alcx.totalSupply(), {'from': account})
        mock_vault.deposit(amount, {'from': account})

    for account in [bob, charlie, dave]:
        assert mock_vault.balanceOf(account) == mock_vault.balanceOf(alice)

    mock_vault.withdraw(amount, {'from': alice})
    alice_fee = amount * 250 // 10000
    assert alcx.balanceOf(alice) == prior_alcx_balance_alice - alice_fee

    mock_vault.withdraw(amount, {'from': bob})
    bob_gain = (alice_fee // 3)
    bob_fee = (amount + bob_gain) * 250 // 10000
    assert alcx.balanceOf(bob) == prior_alcx_balance_bob + bob_gain - bob_fee

    mock_vault.withdraw(amount, {'from': charlie})
    charlie_gain = bob_gain + (bob_fee // 2)
    charlie_fee = (amount + charlie_gain) * 250 // 10000
    assert math.isclose(alcx.balanceOf(charlie), prior_alcx_balance_charlie + charlie_gain - charlie_fee, rel_tol=1)

    pool_balance = mock_ss_compounder.totalPoolBalance()
    mock_vault.withdraw(amount, {'from': dave})
    dave_gain = charlie_gain + charlie_fee
    assert math.isclose(alcx.balanceOf(dave), prior_alcx_balance_dave + pool_balance - amount, rel_tol=1)
    assert math.isclose(alcx.balanceOf(dave), prior_alcx_balance_dave + dave_gain, rel_tol=1)

    assert mock_ss_compounder.totalPoolBalance() == 0
    assert mock_vault.totalSupply() == 0

    balances = 0
    for account in [alice, bob, charlie, dave]:
        balances += alcx.balanceOf(account)
        assert mock_vault.balanceOf(account) == 0

    assert balances == (prior_alcx_balance_alice + prior_alcx_balance_bob +
                        prior_alcx_balance_charlie + prior_alcx_balance_dave)


def test_with_simulated_harvest_mock(alice, bob, charlie, dave, mock_vault, alcx, mock_ss_compounder, mock_pool, owner):

    amount = 1000
    harvest = 400

    prior_alcx_balance_alice = alcx.balanceOf(alice)
    prior_alcx_balance_bob = alcx.balanceOf(bob)
    prior_alcx_balance_charlie = alcx.balanceOf(charlie)
    prior_alcx_balance_dave = alcx.balanceOf(dave)
    for account in [alice, bob, charlie, dave]:
        alcx.approve(mock_vault, alcx.totalSupply(), {'from': account})
        mock_vault.deposit(amount, {'from': account})

    for account in [bob, charlie, dave]:
        assert mock_vault.balanceOf(account) == mock_vault.balanceOf(alice)

    alcx.approve(mock_pool, harvest, {'from': owner})
    mock_pool.deposit(0, harvest, {'from': owner})

    mock_vault.withdraw(amount, {'from': alice})
    harvest_gain = harvest // 4
    alice_fee = (amount + harvest_gain) * 250 // 10000
    assert alcx.balanceOf(alice) == prior_alcx_balance_alice + harvest_gain - alice_fee

    mock_vault.withdraw(amount, {'from': bob})
    bob_gain = (alice_fee // 3) + harvest_gain
    bob_fee = (amount + bob_gain) * 250 // 10000
    assert alcx.balanceOf(bob) == prior_alcx_balance_bob + bob_gain - bob_fee

    mock_vault.withdraw(amount, {'from': charlie})
    charlie_gain = bob_gain + (bob_fee // 2) + harvest_gain
    charlie_fee = (amount + charlie_gain) * 250 // 10000
    assert math.isclose(alcx.balanceOf(charlie), prior_alcx_balance_charlie + charlie_gain - charlie_fee, rel_tol=1)

    pool_balance = mock_ss_compounder.totalPoolBalance()
    mock_vault.withdraw(amount, {'from': dave})
    dave_gain = charlie_gain + charlie_fee + harvest_gain
    assert math.isclose(alcx.balanceOf(dave), prior_alcx_balance_dave + pool_balance - amount, rel_tol=1)
    assert math.isclose(alcx.balanceOf(dave), prior_alcx_balance_dave + dave_gain, rel_tol=1)

    assert mock_ss_compounder.totalPoolBalance() == 0
    assert mock_vault.totalSupply() == 0

    balances = 0
    for account in [alice, bob, charlie, dave]:
        balances += alcx.balanceOf(account)
        assert mock_vault.balanceOf(account) == 0
