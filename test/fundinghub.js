var BigNumber = require('bignumber');
// var DefaultBuilder = require("truffle-default-builder");
// var PuddingGenerator = require("ether-pudding/generator");
// var Pudding = require("ether-pudding");
// var web3 = require("web3");
// var web3 = new Web3(new Web3.providers.HttpProvider(
//  "http://" + rpcConfig.host + ":" + rpcConfig.port));
// Pudding.setWeb3(web3);

var accounts = 0;

contract('FundingHub', function(accounts_) {
  var project1 = 0;
  accounts = accounts_

  it("should retrieve zero projects if none put in", function() {
    var fundhub = FundingHub.deployed();

    return fundhub.browse().then(function(projects) {
      assert.equal(projects.length, 0, '1 or more projects are present when 0 where inserted');
    })
  });
  it("should create a new project with correct storage values", function(done) {
    var fundhub = FundingHub.deployed();
    var owner = accounts[0];
    var targetFunding = 10.5;
    var targetFundingWei = web3.toWei(targetFunding, 'ether');
    var timeoffset = 3; // seconds
    var deadline = Math.round(+new Date()/1000) + timeoffset;

    fundhub.E_createProject().watch(function (error, result) {
      var projectAddress = result['args']['projectAddress'];
      project1 = projectAddress;
      _getProjectInfo(projectAddress, function (fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual) {
        assert.equal(fundHubAddrActual, fundhub.address, 'Created project\'s Fundhub address does not match');
        assert.equal(ownerAddrActual, owner, 'Created project\'s owner address does not match');
        assert.equal(Math.abs(secondsToDeadlineActual - timeoffset) < 10, true, 'Created projects deadline does not match');
        assert.equal(targetFundsWeiActual, targetFundingWei, 'Created project\'s target fund does not match - ' + targetFundsWeiActual + ' - ' + targetFundingWei);
        assert.equal(totalFundsWeiActual, web3.toWei(0,'ether'), 'Created project\'s balance is not 0 - is ' + totalFundsWeiActual);
      });
    });

    fundhub.createProject(owner, targetFundingWei, deadline).then(function (txAddr) {;}).catch(function(error){assert.equal(0,1,'Fail: ' + error);});
    setTimeout(done, 1500);
  });
  it("refund users if past target date and under funded", function(done) {
    var fundhub = FundingHub.deployed();
    var accountA = accounts[1];
    var accountB = accounts[2];
    var fundedAmountA = web3.toBigNumber(web3.toWei(2, 'ether'));
    var fundedAmountB = web3.toBigNumber(web3.toWei(5, 'ether'));
    var startBalanceA = web3.eth.getBalance(accountA);
    var startBalanceB = web3.eth.getBalance(accountB);

      _contribute(project1, accountA, accounts[0], fundedAmountA, function(contributionSuccessful) {
          assert.equal(true, contributionSuccessful, 'Contribution not succesful.');
          _contribute(project1, accountB, accounts[0], fundedAmountB, function(contributionSuccessful) {
              assert.equal(true, contributionSuccessful, 'Contribution not succesful.');

              var balanceA_fundedProjectState = startBalanceA; // NOTE: account A is a contributor but does not fund it
              var balanceB_fundedProjectState = startBalanceB; // NOTE: account B is a contributor but does not fund it
              var balanceProject1_fundedProjectState_ = fundedAmountA.plus(fundedAmountB);
              var balanceA_refundedAccountsState = startBalanceA.plus(fundedAmountA);
              var balanceB_refundedAccountsState = startBalanceB.plus(fundedAmountB);
              var balanceProject1_refundedAccountsState = web3.toBigNumber(0);

              testBalances(0, 'Funded Project State - ', project1, accountA, accountB, balanceProject1_fundedProjectState_, balanceA_fundedProjectState, balanceB_fundedProjectState);
              setTimeout(function() {
                  _contribute(project1, accounts[0], accounts[0], 1000, function(contributionSuccessful) {
                      assert.equal(true, contributionSuccessful, 'Contribution not succesful.');
                      testBalances(0, 'Refunded Accounts State - ', project1, accountA, accountB, balanceProject1_refundedAccountsState, balanceA_refundedAccountsState, balanceB_refundedAccountsState, done);
                  });
              }, 4000);

          });
      });
  });
});


var testBalances = function(delay, testMsgPrefix, project, accountA, accountB, expectedBalanceProject, expectedBalanceA, expectedBalanceB, endFn) {
    endFn = endFn || false;
    var f = function() {
        assert.equal(web3.eth.getBalance(project).toString(10), expectedBalanceProject.toString(10), testMsgPrefix + 'project balance does not match');
        assert.equal(web3.eth.getBalance(accountA).toString(10), expectedBalanceA.toString(10), testMsgPrefix + 'accountA balance does not match');
        assert.equal(web3.eth.getBalance(accountB).toString(10), expectedBalanceB.toString(10), testMsgPrefix + 'accountB balance does not match');
        if (endFn) endFn();
    }

    if (delay == 0) { 
        f(); 
        return;
    }
    setTimeout(f , delay);
}

var _contribute = function (projAddr, contrib, fromAccount, amount, f) {
    FundingHub.deployed().contribute(projAddr, accounts[0], {from: accounts[0], value: amount}) // TODO: This is not based on input project address
        .then(function (txAddr) {
            
            var eventContrib = FundingHub.deployed().E_contribute();
            eventContrib.watch(function (error, result) {
                eventContrib.stopWatching();
                if (error) assert.equal(0,1, error);
                f(result['args']['contributionSuccessful'], eventContrib);
            });
        }).catch(function(e){assert.equal(0,1,e)} )
};

var _getProjectInfo = function (projectAddress, fn) {
      Project.at(projectAddress).getProjectInfo()
        .then(function (params) {
          [fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual] = params;
          fn(fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual);
        }).catch(function (error) { assert.ifError(error);
      });
};

