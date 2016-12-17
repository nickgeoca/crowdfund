const Web3 = require("web3");
// const Web3 = require('ethereum.js')
const FundingHub = require("../contracts/FundingHub.sol.js");
const Migrations = require("../contracts/Migrations.sol.js");


// Supports Mist, and other wallets that provide 'web3'.
if (typeof web3 !== 'undefined')    // Use the Mist/wallet provider.
    web3 = new Web3(web3.currentProvider);
else                                // Use the provider from the config.
    web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

[FundingHub, Migrations].forEach(function(contract) {
    contract.setProvider(web3.currentProvider);
});

console.log(web3.eth.accounts);

/*
FundingHub.deployed().getBalance.call(web3.eth.accounts[0])
    .then(function (balance) {
	console.log("balance: " + balance.toString(10));
    })
    .catch(function (err) {
	console.error(err);
    });
*/
