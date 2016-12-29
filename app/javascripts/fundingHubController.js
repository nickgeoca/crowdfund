var app = angular.module('fundingHubApp', []);
var TODO_REMOVE;
app.config(function ($locationProvider) {
  $locationProvider.html5Mode(true);
});

var errorFunction = function(e) {
    console.log(e);
    $timeout(function () {
        $scope.userStatus = ("Error contributing project; see log.");
    });
}

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

      $timeout(function () {  
        $scope.accounts = accs;
        $scope.account = $scope.accounts[0];
      });
      console.log('TODO: this format: a1-balance1 .. a2-balance2 .. etc');  
    });
  }


  $scope.createProject = function (fundhubAddress, ownerAddress, targetFundingEther, deadlineUnixTimestamp) {

    // TODO: For all events, problem if watches never happen (memory leak)

    c_fh.E_createProject().watch(function (error, result) {
      // this.stopWatching(); TODO: maybe get this working?
      if (error) {
        console.log(error);
        $timeout(function () {
          $scope.userStatus = ("Error contributing project; see log.");
        });
        return;
      }

      // projectOwner   = result['args']['projectOwner'];
      projectAddress = result['args']['projectAddress'];
      $timeout(function () {
        $scope.userStatus = 'Transaction complete!';
        $scope.projectAddress = projectAddress;
      });
    });

    console.log('TODO: Use fundhubAddress -- ' + "myContractInstance = MyContract.at('0x78e97bcc5b5dd9ed228fed7a4887c0d7287344a9');");
    console.log('TODO: How to assure params are valid/not-null??');        
    console.log('FundingHub Address:' + c_fh.address);
    $scope.userStatus = 'Creating project...';

    c_fh.createProject(ownerAddress,  web3.toWei(targetFundingEther), deadlineUnixTimestamp, {from: $scope.account, gas:1000000})
      .then(function(txAddr) {
        console.log('Transaction Address: ' + txAddr); 
        $timeout(function () {
          $scope.userStatus = '...getting project address.'; // TODO: This is out of order w/ transaction complete
        });
      }).catch(errorFunction);
  }

  $scope.contribute = function (fundhubAddress, projectAddress, amountEither) {
    console.log('TODO: Use fundhubAddress');
    console.log('TODO: How to assure params are valid/not-null??');        
    console.log('FundingHub Address:' + c_fh.address);
    $scope.userStatus = 'Contributing project...';

    c_fh.E_contribute().watch(function (error, result) {
      // this.stopWatching(); TODO: maybe get this working?
      if (error) {
        console.log(error);
        $timeout(function () {
          $scope.userStatus = ("Error contributing project; see log.");
        });
        return;
      }

        
      contributionSuccessful = result['args']['contributionSuccessful'];
      var msg_ = contributionSuccessful ? 'successful!' : 'failed!';
      var msg  = 'Contribution to ' + projectAddress + ' - ' + msg_;
      $timeout(function () {
        $scope.userStatus = msg;
      });
      console.log(msg);
    });

    c_fh.contribute(projectAddress, $scope.account, {from: $scope.account, value: web3.toWei(amountEither), gas:1000000})
      .then(function(txAddr) {
        console.log('Transaction Address: ' + txAddr); 
        $timeout(function () {
          $scope.userStatus = 'Checking if contribution sucessful...';
        });
      }).catch(errorFunction);
  }

  $scope.browseProjects = function (fundhubAddress) {
    console.log('TODO: Use fundhubAddress');
    console.log('TODO: How to assure params are valid/not-null??');        
    console.log('FundingHub Address:' + c_fh.address);
    $scope.userStatus = 'Getting projects...';

    c_fh.browse() 
          .then(function(projects) {
            infoProjects = projects.map(function(pAddr) {
              var p = Project.at(pAddr);
              return p.getProjectInfo();
            });
            return Promise.all(infoProjects).map(function(info, i){ return [projects[i]].concat(info);});  
          })
          .then(function (infoProjects){
              infoProjects.map( function (tup){
                [projectAddr, fundHubAddr, ownerAddr, secondsToDeadline, targetFundsWei, totalFundsWei] = tup;
                var targetFundsEther = web3.fromWei(targetFundsWei, 'ether').toString(10);
                var totalFundsEther = web3.fromWei(totalFundsWei, 'ether').toString(10);
                var deadline = secondsToDeadline.plus(Math.floor(Date.now() / 1000));
                deadline = 1000 * deadline;
                deadline = new Date(deadline);
                deadline = deadline.toString();

                console.log('--------------------------------');
                console.log('Project Address: ' + projectAddr);  
                console.log(' - FundHub Address: ' + fundHubAddr);
                console.log(' - Owner Address: ' + ownerAddr);
                console.log(' - Deadline: ' + deadline);
                console.log(' - Target Funding: ' + targetFundsEther);
                console.log(' - Total Funding: ' + totalFundsEther);                               
              });
            $timeout(function () {
              $scope.userStatus = infoProjects.length + ' projects listed in console!';
            });
          })
          .catch(errorFunction);
              // Promise.resolve(1).then(x => Promise.all([x, x+1])).then(([a,b])=>a+b).then(console.log)
    }                             

}]);

// TODO: Get this to work on mist wallet?
// TODO: Sort out r/w project address in ui
