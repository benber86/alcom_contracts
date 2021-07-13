import brownie
import pytest
POOL_ID = 1


@pytest.mark.parametrize("amount", [1, 100, 10**18])
def test_mock_deposit(alice, bob, charlie, dave, amount, alcx, mock_vault, mock_compounder, mock_pool):

    prior_alcx_balance = alcx.balanceOf(alice)
    alcx.approve(mock_vault, amount, {'from': alice})
    alcx.approve(mock_vault, amount, {'from': bob})
    alcx.approve(mock_vault, amount, {'from': charlie})
    alcx.approve(mock_vault, amount, {'from': dave})

    mock_vault.deposit(amount, {'from': alice})
    mock_vault.deposit(amount, {'from': bob})
    mock_vault.deposit(amount, {'from': charlie})
    mock_vault.deposit(amount, {'from': dave})

    assert mock_vault.balanceOf(alice) == amount
    assert mock_vault.balanceOf(bob) == amount
    assert mock_vault.balanceOf(charlie) == amount
    assert mock_vault.balanceOf(dave) == amount
    assert mock_pool.getPoolTotalDeposited(POOL_ID) == amount * 4
    assert mock_vault.totalSupply() == amount * 4
    assert mock_compounder.stakeBalance() == amount * 4
    assert alcx.balanceOf(alice) == prior_alcx_balance - amount
