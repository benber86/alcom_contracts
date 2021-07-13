import brownie
from brownie.test import strategy
from brownie import chain
from brownie import Contract
import math

DAY = 86400
WETH = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
ALCX = '0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF'
SUSHI_ROUTER = '0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F'
ALCX_POOL = '0xAB8e74017a8Cc7c15FFcCd726603790d26d7DeCa'


class StateMachine:

    value = strategy("uint256", min_value=100, max_value="10 ether")
    days = strategy("uint256", min_value=1, max_value=10)
    address = strategy("address", length=6)

    def __init__(self, accounts, compounder, vault, alcx_pool, alcx, sushi):
        self.accounts = accounts
        self.compounder = compounder
        self.vault = vault
        self.alcx_pool = alcx_pool
        self.alcx = alcx
        self.sushi = sushi

    def setup(self):
        for account in self.accounts:
            self.sushi.swapExactETHForTokens(
                1,
                [WETH, ALCX],
                account,
                9999999999,
                {
                    "from": account,
                    "value": "50 ether"
                }
            )
        self.alcx.approve(self.vault, 1, {'from': self.accounts[0]})
        self.vault.deposit(1, {'from': self.accounts[0]})

    def rule_deposit(self, address, value):
        if self.alcx.balanceOf(address) < value:
            return
        self.alcx.approve(self.vault, 2**256 - 1, {'from': address})
        self.vault.deposit(value, {'from': address})

    def rule_let_yield_accumulate(self):
        chain.sleep(DAY * 10)

    def rule_harvest(self):
        self.compounder.harvest({'from': self.accounts[0]})

    def teardown_final(self):
        for i, account in enumerate(self.accounts):
            shares = self.vault.balanceOf(account)
            if shares == 0:
                continue
            claimable = shares * self.compounder.stakeBalance() // self.vault.totalSupply()
            fee = claimable * 250 // 10000
            prior_alcx_balance = self.alcx.balanceOf(account)
            self.vault.withdrawAll({'from': account})
            withdrawn = self.alcx.balanceOf(account) - prior_alcx_balance
            if i != len(self.accounts) - 1:
                assert math.isclose(withdrawn, claimable - fee, rel_tol=10)

        assert self.vault.totalSupply() == 0
        assert self.compounder.totalPoolBalance() == 0


def test_vault_deposit_withdraw(
    state_machine, accounts, Compounder, Vault
):
    alcx = Contract.from_explorer(ALCX)
    alcx_pool = Contract.from_explorer(ALCX_POOL)
    sushi = Contract.from_explorer(SUSHI_ROUTER)
    vault = Vault.deploy({"from": accounts[0]})
    compounder = Compounder.deploy(vault, ALCX_POOL, {"from": accounts[0]})
    vault.setCompounder(compounder, {"from": accounts[0]})
    state_machine(
        StateMachine,
        accounts[:6],
        compounder,
        vault,
        alcx_pool,
        alcx,
        sushi,
        settings={"max_examples": 50},
    )
