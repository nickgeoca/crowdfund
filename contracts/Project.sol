pragma solidity ^0.4.6;

// FundingHub is the registry of all Projects to be funded. FundingHub should have a constructor and the following functions:

// TODO: What to do after payout/refund?
// a Leave Project as is
// b Kill Project
// c Delete mappings

contract Project {

  // *******************
  //      Types

  // Iterable map. Add only. Unique addresses.
  // TODO: Change names in data type below
  struct ContributorsFunds {
    mapping (address => uint) contributorToFunds;
    address[] indexedContributors;
  }


  function addFundsToContributor(ContributorsFunds storage d, address contrib, uint funds) private {
    bool isNew = d.contributorToFunds[contrib] == 0;

    if (isNew) 
      d.indexedContributors.push(contrib);

    d.contributorToFunds[contrib] = d.contributorToFunds[contrib] + funds;
  }

  // TODO: param f: (address addr, uint funds)
  function mapContributorFunds ( ContributorsFunds storage d
                               , function (address, uint) f)
    private
  {
    uint i;
    uint end = d.indexedContributors.length; 
    uint funds;
    address addr;

    for (i = 0; i < end; i++) {
      addr = d.indexedContributors[i];
      funds = d.contributorToFunds[addr];

      f(addr, funds);
    }
  }

  // *******************
  //      Storage
  uint private deadline_;
  address private owner_;
  uint private targetFundsWei_;
  uint private totalFundsWei_;  
  ContributorsFunds private contributorsDB_;

  // *****************
  // Public functions
  function Project ( address owner
                   , uint targetFundingWei
                   , uint deadlineBlockchainTimestamp)
    isAddressValid(owner)
  {
    deadline_ = deadlineBlockchainTimestamp;
  }

  // Called when FundingHub gets contribution (fn: contribute)
  // Returns if project ended or not
  function fund(address contributor, uint fundsWei)
    isAddressValid(contributor)
    isEnoughFunds(fundsWei)
    returns (bool)
  {
    bool metGoal = (fundsWei + totalFundsWei_) >= targetFundsWei_;
    bool atTimeLimit = block.timestamp >= deadline_;
    uint leftOverFunds = metGoal ? fundsWei + totalFundsWei_ - targetFundsWei_
                                 : 0;
    bool projectEnd = metGoal | atTimeLimit;

    // Send any leftovers back and add contribution 
    sendTo(contributor, leftOverFunds);
    addFundsToContributor(contributorsDB_, contributor, fundsWei - leftOverFunds);

    if (metGoal)
      payout();
    else if (atTimeLimit)
      refund();

    return projectEnd;
  }

  // Sends all funds received to owner of the project
  function payout() {
    sendTo(owner_, this.balance);
    // TODO: PUT EVENT HERE 
  }

  /*
    NOTE: HOW DOES ONE SEND ALL CONTRIBUTIONS BACK IF EXPENSIVE?
    a. Unlucky guy's gotta pay a lot
    b. this contract uses some funding
    c. if no one does it, owner of contract does it
  */

  // sends all individual contributions back to the respective contributor
  function refund() {
    mapContributorFunds(contributorsDB_, sendTo);
    // TODO:   PUT EVENT HERE STATING WHAT WAS/WASN't SEND BACK'; AMEN
  }

  function exists() returns (bool) {
    return owner_ != 0;
  }

  // ***********************
  // Helper functions
  function sendTo(address recipient, uint bal) private {
    if (bal == 0) return;                // NOTE: Consider optimization of removing this line during a map.
    if (!recipient.send(bal)) throw;
  }

  
  // ***********************
  // Modifiers
  modifier isAddressValid (address recipient) {
    if (recipient == 0) throw;
    _;
  }

  modifier isEnoughFunds (uint funds) {
    if (funds == 0) throw;
    _;
  }
  
}

