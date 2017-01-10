var BigNumber = require('bignumber');

var accounts = 0;

contract('FundingHub', function(accounts_) {
  var project1 = 0;
  accounts = accounts_
  it("should retrieve zero projects if none put in", function(done) {
    var fundhub = FundingHub.deployed();

    return fundhub.browse().then(function(projects) {
      assert.equal(projects.length, 0, '1 or more projects are present when 0 where inserted');
    }).then(done).catch(function(error){done(error);});
  });
  it("should create a new project with correct storage values", function(done) {
    var fundhub = FundingHub.deployed();
    var owner = accounts[0];
    var targetFunding = 10.5;
    var targetFundingWei = web3.toWei(targetFunding, 'ether');
    var projectDuration = 4; // seconds
    var deadline = Math.round(+new Date()/1000) + projectDuration;

    return fundhub.createProject.sendTransaction(owner, targetFundingWei, deadline).then(function (txAddr) {
      var event = fundhub.E_createProject();
      event.watch(function(error, result){ 
        event.stopWatching();
        if (error) done(error);
        project1 = result['args']['projectAddress'];
      });
    }).then(
      delay(500)
    ).then(function(){
        return Project.at(project1).getProjectInfo.call();
    }).then(function(params) {
      [fundHubAddrActual, ownerAddrActual, secondsToDeadlineActual, targetFundsWeiActual, totalFundsWeiActual] = params;
      assert.equal(fundHubAddrActual, fundhub.address, 'Created project\'s Fundhub address does not match');
      assert.equal(ownerAddrActual, owner, 'Created project\'s owner address does not match');
      assert.equal(Math.abs(secondsToDeadlineActual - projectDuration) < 5, true, 'Created projects deadline does not match');
      assert.equal(targetFundsWeiActual, targetFundingWei, 'Created project\'s target fund does not match - ' + targetFundsWeiActual + ' - ' + targetFundingWei);
      assert.equal(totalFundsWeiActual, web3.toWei(0,'ether'), 'Created project\'s balance is not 0 - is ' + totalFundsWeiActual);
    }).then(done).catch(function(error){done(error);});
  });
  it("refund users if past target date and under funded", function(done) {
    var testBalance = function(account, accountExpectedBalance, errorMsgPrefix) {
      var actualBalance = web3.eth.getBalance(account).toString(10);
      var expectedBalance = accountExpectedBalance.toString(10);
      assert.equal(actualBalance, expectedBalance, errorMsgPrefix);
    }

    var fundhub = FundingHub.deployed();
    var accountA = accounts[1];
    var accountB = accounts[2];
    var fundedAmountA = web3.toBigNumber(web3.toWei(2, 'ether'));
    var fundedAmountB = web3.toBigNumber(web3.toWei(5, 'ether'));
    var balanceA_startState = web3.eth.getBalance(accountA);
    var balanceB_startState = web3.eth.getBalance(accountB);

    var balanceA_fundedProjectState = balanceA_startState; // NOTE: account A is a contributor but does not fund it
    var balanceB_fundedProjectState = balanceB_startState; // NOTE: account B is a contributor but does not fund it
    var balanceProject1_fundedProjectState = fundedAmountA.plus(fundedAmountB);
    var balanceA_refundedAccountsState = balanceA_startState.plus(fundedAmountA);
    var balanceB_refundedAccountsState = balanceB_startState.plus(fundedAmountB);
    var balanceProject1_refundedAccountsState = web3.toBigNumber(0);

    return fundhub.contribute(project1, accountA, {from: accounts[0], value: fundedAmountA}
       ).then(function (txAddr) {
         return fundhub.contribute(project1, accountB, {from: accounts[0], value: fundedAmountB});
      }).then(function (txAddr) {
        testBalance(project1, balanceProject1_fundedProjectState, 'Funded Project State - project balance does not match');
        testBalance(accountA, balanceA_fundedProjectState, 'Funded Project State - accountA balance does not match');
        testBalance(accountB, balanceB_fundedProjectState, 'Funded Project State - accountB balance does not match');
      }).then(
        delay(5000)
      ).then(function(){
        return fundhub.contribute(project1, accounts[0], {from: accounts[0], value: 1000});
      }).then(function(txAddr) {
        testBalance(project1, balanceProject1_refundedAccountsState, 'Refunded Accounts State - project balance does not match');
        testBalance(accountA, balanceA_refundedAccountsState, 'Refunded Accounts State - accountA balance does not match');
        testBalance(accountB, balanceB_refundedAccountsState, 'Refunded Accounts State - accountB balance does not match');
      }).then(done).catch(function(error){done(error);});
  });
});


function delay(milliseconds) {
  return function(result) {
    return new Promise(function(resolve, reject) {
      setTimeout(function() {
        resolve(result);
      }, milliseconds);
    });
  };
}
