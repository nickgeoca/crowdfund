module.exports = function(deployer) {
  deployer.autolink();  
  unixTimestamp = web3.toBigNumber(Math.round(+new Date()/1000));
  deployer.deploy(FundingHub, unixTimestamp);
};
