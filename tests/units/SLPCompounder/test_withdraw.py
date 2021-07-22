import brownie


def test_withdraw_not_vault(vault, ss_compounder, owner):
    with brownie.reverts():
        ss_compounder.withdraw('1 ether', {'from': owner})
