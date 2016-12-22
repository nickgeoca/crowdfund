var app = angular.module('fundingHubApp', []);
var TODO_REMOVE;
app.config(function ($locationProvider) {
  $locationProvider.html5Mode(true);
});

app.controller("fundingHubController", [ '$scope', '$location', '$http', '$q', '$window', '$timeout', function($scope , $location, $http, $q, $window, $timeout) {
  $scope.accounts = [];
  $scope.account = "";
  $scope.projectAddress = "N/A";
  $scope.userStatus = "";
  var c_fh;

  $window.onload = function () {
    c_fh = FundingHub.deployed();

    // Load accounts
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }
    
      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      $scope.accounts = accs;
      $scope.account = $scope.accounts[0];
      console.log('TODO: this format: a1-balance1 .. a2-balance2 .. etc');  
    });
  }


  $scope.createProject = function (fundhubAddress, ownerAddress, targetFundingEther, deadlineUnixTimestamp) {

    // NOTE: This could be problem in future if watches never happen

    // {projectOwner: ownerAddress});
    c_fh.E_newProject().watch(function (error, result) {
      // this.stopWatching();
      if (error) {
        console.log(error);
        $scope.userStatus = ("Error contributing project; see log.");
        return;
      }

      pAddr = result['args']['yo'];
      $scope.userStatus = 'Transaction complete & project address fetched!';
      $scope.projectAddress = pAddr.valueOf();
    });

    console.log('TODO: Use fundhubAddress -- ' + "myContractInstance = MyContract.at('0x78e97bcc5b5dd9ed228fed7a4887c0d7287344a9');");
    console.log('TODO: How to assure params are valid/not-null??');        
    console.log('FundingHub Address:' + c_fh.address);
    $scope.userStatus = 'Creating project...';

    c_fh.createProject(ownerAddress,  web3.toWei(targetFundingEther), deadlineUnixTimestamp, {from: $scope.account, gas:1000000})
      .then(function(txAddr) {
        console.log('Transaction Address: ' + txAddr); 
        $timeout(function () {
          $scope.userStatus = 'Transaction complete.... getting project address.';
        });
      }).catch(function(e) {
        console.log(e);
        $scope.userStatus = ("Error creating project; see log.");
      })
  }

  $scope.contribute = function (fundhubAddress, projectAddress, amountEither) {
    console.log('TODO: Use fundhubAddress');
    console.log('TODO: How to assure params are valid/not-null??');        
    console.log('FundingHub Address:' + c_fh.address);
    $scope.userStatus = 'Contributing project...';

    c_fh.contribute(projectAddress, $scope.account, {from: $scope.account, value: web3.toWei(amountEither)})
      .then(function(success) {
        success = success.valueOf();
        console.log('Contribution was success-' + success); 
        $timeout(function () {
          $scope.userStatus = 'Transaction complete! Contribution success?' + success;
        });
      }).catch(function(e) {
        console.log(e);
        $scope.userStatus = ("Error contributing project; see log.");
      })
  }


}]);

// Create
// browse
// contribute
