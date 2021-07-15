import pytest
from brownie import Vault, SingleStakeCompounder, MockPool, Contract

WETH = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
ALCX = '0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF'
SUSHI_ROUTER = '0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F'
ALCX_POOL = '0xAB8e74017a8Cc7c15FFcCd726603790d26d7DeCa'


@pytest.fixture(scope="session")
def alcx():
    yield Contract.from_explorer(ALCX)


@pytest.fixture(scope="session")
def alcx_pool():
    yield Contract.from_explorer(ALCX_POOL)


@pytest.fixture(scope="session")
def sushiswap_alcx_exchange():
    yield Contract.from_explorer(SUSHI_ROUTER)


@pytest.fixture(scope="session")
def alice(accounts):
    yield accounts[1]


@pytest.fixture(scope="session")
def bob(accounts):
    yield accounts[2]


@pytest.fixture(scope="session")
def charlie(accounts):
    yield accounts[3]


@pytest.fixture(scope="session")
def dave(accounts):
    yield accounts[4]


@pytest.fixture(scope="session")
def erin(accounts):
    yield accounts[5]


@pytest.fixture(scope="session")
def owner(accounts):
    yield accounts[0]


@pytest.fixture(scope="session")
def no_coiner(accounts):
    yield accounts[6]


@pytest.fixture(scope="function")
def vault(Vault, owner):
    yield Vault.deploy(ALCX, {"from": owner})


@pytest.fixture(scope="function")
def mock_vault(Vault, owner):
    yield Vault.deploy(ALCX, {"from": owner})


@pytest.fixture(scope="function")
def ss_compounder(SingleStakeCompounder, vault, owner):
    comp = SingleStakeCompounder.deploy(vault,
                                        ALCX_POOL,
                                        {"from": owner})
    vault.setCompounder(comp, {"from": owner})
    yield comp


@pytest.fixture(scope="function")
def mock_pool(MockPool, alcx, owner):
    yield MockPool.deploy(alcx, {"from": owner})


@pytest.fixture(scope="function")
def mock_ss_compounder(SingleStakeCompounder, mock_vault, mock_pool, owner):
    comp = SingleStakeCompounder.deploy(mock_vault,
                                        mock_pool.address,
                                        {"from": owner})
    mock_vault.setCompounder(comp, {"from": owner})
    yield comp


@pytest.fixture(scope="session", autouse=True)
def buy_alcx(accounts, sushiswap_alcx_exchange):
    for account in accounts[:6]:
        sushiswap_alcx_exchange.swapExactETHForTokens(
            1,
            [WETH, ALCX],
            account,
            9999999999,
            {
                "from": account,
                "value": "50 ether"
            }
        )
