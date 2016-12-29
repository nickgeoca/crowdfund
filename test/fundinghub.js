// var DefaultBuilder = require("truffle-default-builder");
// var PuddingGenerator = require("ether-pudding/generator");
// var Pudding = require("ether-pudding");
// var web3 = require("web3");
// var web3 = new Web3(new Web3.providers.HttpProvider(
//  "http://" + rpcConfig.host + ":" + rpcConfig.port));
// Pudding.setWeb3(web3);

var project1 = 0;

contract('FundingHub', function(accounts) {

  it("should retrieve zero projects if none put in", function() {
    var fundhub = FundingHub.deployed();

    return fundhub.browse().then(function(projects) {
      assert.equal(projects.length, 0, '1 or more projects are present when 0 where inserted');
    })
  });
  it("should create a new project with correct storage values", function() {
    var fundhub = FundingHub.deployed();
    var owner = accounts[1];
    var targetFunding = 10.5;
    var targetFundingWei = web3.toWei(targetFunding, 'ether');
    var timeoffset = 3600; // One hour
    var deadline = Math.round(+new Date()/1000) + timeoffset;

    fundhub.E_createProject().watch(function (error, result) {
      var projectAddress = result['args']['projectAddress'];
      project1 = projectAddress;
        assert.equal(0,1,'fail!!!!');
      _getProjectInfo(projectAddress, function (fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual) {
        assert.equal(fundHubAddrActual, fundhub.address, 'Created project\'s Fundhub address does not match');
        assert.equal(ownerAddrActual, owner, 'Created project\'s owner address does not match');
        assert.equal(Math.abs(secondsToDeadlineActual - timeoffset) < 10, true, 'Created projects deadline does not match');
        assert.equal(targetFundsWeiActual, targetFundingWei, 'Created project\'s target fund does not match - ' + targetFundsWeiActual + ' - ' + targetFundingWei);
        assert.equal(totalFundsWeiActual, web3.toWei(0,'ether'), 'Created project\'s balance is not 0 - is ' + totalFundsWeiActual);
      });
    });

    fundhub.createProject(owner, targetFundingWei, deadline).then(function (txAddr) {;}).catch(function(error){assert.equal(0,1,'Fail: ' + error);});

    while(project1 == 0) {setTimeout(function(){;}, 100);}
  });
/*
  it("should be able to contribute to a project", function() {
    _getProjectInfo(project1, function (fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual) {
        assert.equal(0,1,'FAIL!')
    });
  });
*/
});

// Create an automated test that covers the refund function in the Project contract using the truffle testing framework. You don't need to write tests for any other functionality.

/*
var filter = web3.eth.filter('pending');
filter.watch(function (error, log) 
filter.stopWatching();
............
[16:11] <graingert> let watcher
[16:11] <graingert> watcher = $scope.$watch(x, () => watcher());
[16:11] <graingert> linman: ^
[16:12] <graingert> linman: but use components and $onChanges
*/

var _getProjectInfo = function (projectAddress, fn) {
      Project.at(projectAddress).getProjectInfo()
        .then(function (params) {
          [fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual] = params;
          fn(fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual);
        }).catch(function (error) { assert.ifError(error);
      });
};

/*
    return meta.getBalance.call(accounts[0]).then(function(outCoinBalance) {
      metaCoinBalance = outCoinBalance.toNumber();
      return meta.getBalanceInEth.call(accounts[0]);
    }).then(function(outCoinBalanceEth) {
      metaCoinEthBalance = outCoinBalanceEth.toNumber();
    }).then(function() {
      assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, "Library function returned unexpeced function, linkage may be broken");
    });

*/

/*
  it("should send coin correctly", function() {
    var meta = MetaCoin.deployed();

    // Get initial balances of first and second account.
    var account_one = accounts[0];
    var account_two = accounts[1];

    var account_one_starting_balance;
    var account_two_starting_balance;
    var account_one_ending_balance;
    var account_two_ending_balance;

    var amount = 10;

    return meta.getBalance.call(account_one).then(function(balance) {
      account_one_starting_balance = balance.toNumber();
      return meta.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_starting_balance = balance.toNumber();
      return meta.sendCoin(account_two, amount, {from: account_one});
    }).then(function() {
      return meta.getBalance.call(account_one);
    }).then(function(balance) {
      account_one_ending_balance = balance.toNumber();
      return meta.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_ending_balance = balance.toNumber();

      assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
      assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
    });
*/
