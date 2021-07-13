## Community Autocompounder for ALCX Pools


### Overview

A contract to provide feeless autocompounding on ALCX pools to the Alchemix community.
The contract currently only targets the single staking pool. The ETH-ALCX SLP will be added soon™.

Users deposit their ALCX in the Vault contract and receive ERC-20 tokens representing their share of 
ownership of the total pool in exchange. Their ALCX funds are transferred do the Compounder contract which
stakes them in the ALCX single-side pool. A `harvest()` function can be called externally to claim and restake
the rewards.

When a user exits, a 0.25% exit fee is applied. This is to prevent people from trying to profit by "timing" the harvest 
(entering the contract right before a harvest and exiting right afterwards with an undue share of the harvest). The fee
goes back to the staking pool and is therefore effectively redistributed to remaining users.

Additional fees may be applied to cover gas costs or to create a revenue stream to the ALCX treasury.

### Setup

#### Dependencies

- [python3](https://www.python.org/)
- [brownie](https://github.com/iamdefinitelyahuman/brownie)
- [brownie-token-tester](https://github.com/iamdefinitelyahuman/brownie-token-tester)
- [ganache-cli](https://github.com/trufflesuite/ganache-cli)

Install the required python dependencies: `pip install -r requirements.txt`
Install the OpenZeppelin contract with brownie's package manager: `brownie pm install OpenZeppelin/openzeppelin-contracts@4.1.0`

#### Running the tests

The majority of the tests require running `ganache` with a mainnet fork. To do so, register to get an
<a href='https://infura.io/'>Infura</a> Project Id. 
Then set the `WEB3_INFURA_PROJECT_ID` environment variable with the Project Id obtained from infura.

Then run:

`brownie test --network mainnet-fork`

### Future developments

- [ ] Improve test suite and increase test coverage
- [ ] Add events
- [ ] Improve contract ownership rules & roles
- [ ] Define a more sustainable fee structure
- [ ] Python script / Keep3r bot to optimize timing of calls to `harvest()`
- [ ] Help with the <a href='https://github.com/benber86/alcom_contracts'>Front-end</a> 


### License

This project is licensed under the [MIT](LICENSE) license.
