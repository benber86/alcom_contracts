import brownie
from brownie import Vault
import pytest


def test_set_compounder_compounder_set(vault, ss_compounder, owner):
    with brownie.reverts():
        vault.setCompounder(ss_compounder, {'from': owner})


def test_set_compounder_not_owner(alice, vault, ss_compounder):
    with brownie.reverts():
        vault.setCompounder(ss_compounder, {'from': alice})

