
var _targetFundingEther = 20;
var _deadlineSecondsInFuture = 3600; // 1 hour out

var createProject = function (ownerAddress, targetFundingEther, deadlineUnixTimestamp) {
  FundingHub.deployed().E_createProject().watch(function (error, result) {
    // this.stopWatching(); TODO: maybe get this working?
    if (error) {
      console.log(error);
      return;
    }
    
    projectAddress = result['args']['projectAddress'];
    console.log('Project Address: ' + projectAddress);
  });

  FundingHub.deployed().createProject(ownerAddress,  web3.toWei(targetFundingEther), deadlineUnixTimestamp, {from: ownerAddress, gas:1000000})
    .then(function(txAddr) {
      console.log('Transaction Address: ' + txAddr); 
      $timeout(function () {
        $scope.userStatus = '...getting project address.'; // TODO: This is out of order w/ transaction complete
      });
    }).catch(errorFunction);
}

module.exports = function(deployer) {
  deployer.deploy(Set);
  deployer.deploy(Project);
  deployer.autolink();  
  unixTimestamp = web3.toBigNumber(Math.round(+new Date()/1000)); // TODO: Use UTC time and assure date is not from system time. Maybe get time from website instead.
  deployer.deploy(FundingHub, unixTimestamp);

  
  console.log(personal.listAccounts[0]);
  deadline = web3.toBigNumber(Math.round(+new Date()/1000)) + _deadlineSecondsInFuture;
  createProject(personal.listAccounts[0], _targetFundingEther, deadline);

};
