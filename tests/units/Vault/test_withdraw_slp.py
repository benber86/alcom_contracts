import brownie

AMOUNT = 10 ** 18


def test_double_withdraw_slp(sushi_lper1, sushi_lper2, slp_vault, slp, slp_compounder):

    prior_slp_balance_sushi_lper1 = slp.balanceOf(sushi_lper1)
    prior_slp_balance_sushi_lper2 = slp.balanceOf(sushi_lper2)
    slp.approve(slp_vault, AMOUNT, {'from': sushi_lper1})
    slp_vault.deposit(AMOUNT, {'from': sushi_lper1})
    slp.approve(slp_vault, AMOUNT, {'from': sushi_lper2})
    slp_vault.deposit(AMOUNT, {'from': sushi_lper2})
    slp_vault.withdraw(AMOUNT, {'from': sushi_lper1})
    slp_vault.withdraw(slp_vault.balanceOf(sushi_lper2), {'from': sushi_lper2})

    assert slp.balanceOf(slp_vault) == 0
    assert slp_vault.totalSupply() == 0
    assert slp_vault.balanceOf(sushi_lper1) == 0
    assert slp.balanceOf(slp_compounder) == 0
    fee = AMOUNT * 250 // 10000

    assert slp.balanceOf(sushi_lper1) == prior_slp_balance_sushi_lper1 - fee
    assert slp.balanceOf(sushi_lper2) >= prior_slp_balance_sushi_lper2
