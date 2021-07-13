import brownie

POOL_ID = 1


def test_get_position_value(alice, vault, bob, compounder, alcx_pool, alcx):
    test_value = 10 ** 18
    alcx.approve(vault, test_value, {'from': alice})
    vault.deposit(test_value, {'from': alice})

    assert vault.getPositionValue.call({'from': alice}) == test_value

    alcx.approve(vault, test_value, {'from': bob})
    vault.deposit(test_value, {'from': bob})

    assert vault.getPositionValue.call({'from': alice}) >= test_value
