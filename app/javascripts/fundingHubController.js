var app = angular.module('fundingHubApp', []);

app.config(function ($locationProvider) {
  $locationProvider.html5Mode(true);
});

app.controller("fundingHubController", [ '$scope', '$location', '$http', '$q', '$window', '$timeout', function($scope , $location, $http, $q, $window, $timeout) {
  $scope.accounts = [];
  $scope.account = "";
  $scope.projectAddress = "N/A";
  $scope.userStatus = "";

  $window.onload = function () {

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
    var c_fh = FundingHub.deployed();
    console.log('TODO: Use fundhubAddress');
    console.log('TODO: How to assure params are valid/not-null??');        
    console.log('TODO: fix toWei thing');        
    console.log('What does the $timeout function do? Where to use/not-use it...');
    console.log('Project address:' + c_fh.address);
    $scope.userStatus = 'Creating project...';

    
    c_fh.createProject(ownerAddress,  web3.toWei(targetFundingEther), deadlineUnixTimestamp, {from: $scope.account})
      .then(function(addr) {
        pAddr = addr.valueOf();
        console.log('Project Address: ' + pAddr); 
        $timeout(function () {
          $scope.userStatus = 'Transaction complete!';
          $scope.projectAddress = pAddr;
        });
      }).catch(function(e) {
        console.log(e);
        $scope.userStatus = ("Error creating project; see log.");
      })
  }

}]);

// Create
// browse
// contribute
