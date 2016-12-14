pragma solidity ^0.4.2;

// FundingHub is the registry of all Projects to be funded. FundingHub should have a constructor and the following functions:

// TODO: How will tihs work??
function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp);

// TODO: What to do after payout/refund?
// a Leave Project as is
// b Kill Project
// c Delete mappings

contract Project {

  // *******************
  // Types

  // Iterable map. Add only. Unique addresses.
  // TODO: Change names in data type below
  struct ContributorsFunds {
    mapping (address => uint) contributorToFunds;
    address[] indexedcontributors;
  }

  function addFundsToContributor(ContributorsFunds d, address contrib, uint funds) private {
    bool isNew = d.contributorToFunds[contrib] == 0;

    if (isNew) 
      d.contributorIndexes.push(contrib)

    d.contributorToFunds[contrib] = d.contributorToFunds[contrib] + funds;
  }

  // *******************
  // Variables
  uint private deadline_;
  address private owner_;
  uint private targetFundsWei_;
  uint private totalFundsWei_;  
  ContributorsFunds private contributorsDB_;

  // *****************
  // Public functions
  function Project ( address owner
                   , uint targetFundingWei
                   , uint16 endYear
                   , uint8 endMonth
                   , uint8 endDay
                   , uint8 endHour)
    isAddressValid(owner)
  {
    deadline_ = toTimestamp(endYear, endMonth, endDay, endHour);
    // DateTime.sol 0x1a6184cd4c5bea62b0116de7962ee7315b7bcbce
  }

  // Called when FundingHub gets contribution (fn: contribute)
  function fund(address contributor, uint fundsWei)
    isAddressValid(contributor)
    isEnoughFunds(fundsWei)
  {
    bool metGoal = (fundsWei + totalFundsWei_) >= targetFundsWei_;
    // TODO: get current time
    bool atTimeLimit = currentTime >= deadline_;
    uint leftOverFunds = metGoal ? fundsWei + totalFundsWei_ - targetFundsWei_
                                 : 0;

    // Send any leftovers back and add contribution 
    sendTo(contributor, leftOverFunds);
    addFundsToContributor(contributorsDB_, contributor, fundsWei - leftOverFunds);

    if (metGoal)
      payout();
    else if (atTimeLimit)
      refund();
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
    uint i;
    uint end = d.indexedContributors.length; 
    uint funds;
    address addr;

    for (i = 0; i < end; i++) {
      addr = d.indexedContributors[i];
      funds = d.contributorToFunds[addr];

      sendTo(addr, funds);
    }
    // TODO:   PUT EVENT HERE STATING WHAT WAS/WASN't SEND BACK'; AMEN
  }

  function exists() returns (bool) {
    return owner_ != 0;
  }

  // ***********************
  // Helper functions
  function sendTo(address recipient, uint bal) private {
    if (bal == 0) return;
    if (!recipient.send(bal)) throw;
  }

  // ***********************
  // Modifiers
  modifier isValidAddress (address recipient) {
    if (recipient == 0) throw;
    _;
  }

  modifier isEnoughFunds (uint funds) {
    if (funds == 0) throw;
    _;

  
}

