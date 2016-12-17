var unixTimestamp = Math.round(+new Date()/1000);

module.exports = function(deployer) {
  deployer.deploy(FundingHub, unixTimestamp);
};
