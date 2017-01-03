module.exports = function(deployer) {
  deployer.autolink();  
  unixTimestamp = web3.toBigNumber(Math.round(+new Date()/1000)); // TODO: Use UTC time and assure date is not from system time. Maybe get time from website instead.
  deployer.deploy(FundingHub, unixTimestamp);
};
