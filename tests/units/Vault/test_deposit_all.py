import brownie

POOL_ID = 1


def test_deposit_all(erin, vault, compounder, alcx, alcx_pool):
    prior_pool_tvl = alcx_pool.getPoolTotalDeposited(POOL_ID)
    prior_alcx_balance = alcx.balanceOf(erin)
    alcx.approve(vault, alcx.balanceOf(erin), {'from': erin})
    vault.depositAll({'from': erin})

    assert vault.balanceOf(erin) == prior_alcx_balance
    assert alcx.balanceOf(erin) == 0
    assert alcx_pool.getPoolTotalDeposited(POOL_ID) == prior_pool_tvl + prior_alcx_balance
    assert vault.totalSupply() == prior_alcx_balance

