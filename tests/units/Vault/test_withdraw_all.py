import brownie


AMOUNT = 10 ** 18


def test_single_withdraw_all(alice, vault, alcx, compounder):

    prior_pool_balance = compounder.stakeBalance()
    prior_alcx_balance = alcx.balanceOf(alice)
    alcx.approve(vault, AMOUNT, {'from': alice})
    vault.deposit(AMOUNT, {'from': alice})
    vault.withdrawAll({'from': alice})

    assert vault.totalSupply() == 0
    assert vault.balanceOf(alice) == 0
    assert alcx.balanceOf(alice) == prior_alcx_balance
    assert compounder.stakeBalance() == prior_pool_balance
