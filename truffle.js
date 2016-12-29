module.exports = {
  build: {
    "index.html": "index.html",
    "app.js": [
      "javascripts/app.js"
    ],
    "fundingHub.js": [
      "javascripts/_vendor/angular.js",
      "javascripts/fundingHubController.js"
    ],
    "app.css": [
      "stylesheets/app.css"
    ],
    "images/": "images/"
  },
  rpc: {
    host: "localhost",
    port: 8545
  }
};

/*
var DefaultBuilder = require("truffle-default-builder");
var PuddingGenerator = require("ether-pudding/generator");
var Pudding = require("ether-pudding");
var Web3 = require("web3");
var web3 = new Web3(new Web3.providers.HttpProvider(
  "http://" + rpcConfig.host + ":" + rpcConfig.port));
Pudding.setWeb3(web3);
*/
