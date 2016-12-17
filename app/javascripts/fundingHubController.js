var app = angular.module('fundingHubApp', []);
var Web3 = require('web3');
var web3 = new Web3();

app.config(function ($locationProvider) {
  $locationProvider.html5Mode(true);
});

app.controller("fundingHubController", [ '$scope', '$location', '$http', '$q', '$window', '$timeout', function($scope , $location, $http, $q, $window, $timeout) {
  $scope.accounts = [];
  $scope.account = "";
  $scope.projectAddress = "N/A";
  $scope.status = "";

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

  $scope.createProject = function (fundhubAddress, ownerAddress, targetFunding, deadlineUnixTimestamp) {
    var fundhub = FundingHub(fundhubAddress); // TODO: Fix this fukin line for krist sayks

    console.log('TODO: How to assure params are valid/not-null??');        
    console.log('TODO: fix toWei thing');        
    console.log('What does the $timeout function do? Where to use/not-use it...');
    $scope.status = 'Creating project...';

    fundhub.createProject(ownerAddress, toWei(targetFunding), deadlineUnixTimestamp, {from: $scope.account}).then(function(addr) {
      $scope.status = 'Transaction complete!';
      $scope.setProjectAddress = addr;
      console.log('Project Address: ' + addr); 
    }).catch(function(e) {
      console.log(e);
      setStatus("Error creating project; see log.");
    });

  }

}]);

// Create
// browse
// contribute

/*

    var meta = MetaCoin.deployed();
  meta.getBalance.call($scope.account, {from: $scope.account})
        .then(function(value) {
            $timeout(function () {
                $scope.balance = value.valueOf();
            });
        }).catch(function(e) {
          console.log(e);
          $scope.status = 'Error getting balance; see log.';
        });
  };
*/
