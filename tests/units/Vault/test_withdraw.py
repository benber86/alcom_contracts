import brownie


AMOUNT = 10 ** 18


def test_single_withdraw(alice, vault, alcx, ss_compounder):

    prior_pool_balance = ss_compounder.stakeBalance()
    prior_alcx_balance = alcx.balanceOf(alice)
    alcx.approve(vault, AMOUNT, {'from': alice})
    vault.deposit(AMOUNT, {'from': alice})
    vault.withdraw(vault.balanceOf(alice), {'from': alice})

    assert vault.totalSupply() == 0
    assert vault.balanceOf(alice) == 0
    assert alcx.balanceOf(ss_compounder) == 0
    assert alcx.balanceOf(alice) >= prior_alcx_balance
    assert ss_compounder.stakeBalance() == prior_pool_balance


def test_double_withdraw(alice, bob, vault, alcx, ss_compounder):

    prior_alcx_balance_alice = alcx.balanceOf(alice)
    prior_alcx_balance_bob = alcx.balanceOf(bob)
    alcx.approve(vault, AMOUNT, {'from': alice})
    vault.deposit(AMOUNT, {'from': alice})
    alcx.approve(vault, AMOUNT, {'from': bob})
    vault.deposit(AMOUNT, {'from': bob})
    vault.withdraw(AMOUNT, {'from': alice})
    vault.withdraw(vault.balanceOf(bob), {'from': bob})

    assert vault.totalSupply() == 0
    assert alcx.balanceOf(vault) == 0
    assert vault.balanceOf(alice) == 0
    assert alcx.balanceOf(ss_compounder) == 0
    fee = AMOUNT * 250 // 10000
    assert alcx.balanceOf(alice) == prior_alcx_balance_alice - fee
    assert alcx.balanceOf(bob) >= prior_alcx_balance_bob


"""
def test_withdraw_no_coiner(alice, no_coiner, vault, alcx, ss_compounder):
    alcx.approve(vault, AMOUNT, {'from': alice})
    vault.deposit(AMOUNT, {'from': alice})
    with brownie.reverts():
        vault.withdraw(AMOUNT, {'from': no_coiner})
    vault.withdraw(AMOUNT, {'from': alice})


def test_withdraw_non_staker(alice, bob, vault, alcx, ss_compounder):
    alcx.approve(vault, AMOUNT, {'from': alice})
    vault.deposit(AMOUNT, {'from': alice})
    with brownie.reverts():
        vault.withdraw(AMOUNT, {'from': bob})
    vault.withdraw(AMOUNT, {'from': alice})

"""