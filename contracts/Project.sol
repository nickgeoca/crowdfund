pragma solidity 0.4.6;

// TODO: Put Project in own file 

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
  uint private targetFundsWei_;
  address private owner_;
  address private fundhubAddress_;
  ContributorsFunds private contributorsDB_;

  
  // Fallback function
  function() { throw; }

  function Project ( address owner
                   , uint targetFundingWei
                   , uint deadlineBlockchainTimestamp)
    isAddressValid(owner)
  {
    owner_ = owner;
    targetFundsWei_ = targetFundingWei;
    fundhubAddress_ = msg.sender;
    deadline_ = deadlineBlockchainTimestamp;
  }

  // *****************
  // Public functions

  // Called when FundingHub gets contribution (fn: contribute)
  // Returns if project ended or not
  function fund(address contributor, uint fundsWei)
    payable
    isFundingHubAddress(msg.sender)
    isAddressValid(contributor)
    isEnoughFunds(fundsWei)
    returns (bool)
  {
    bool metGoal = this.balance >= targetFundsWei_;
    bool atTimeLimit = block.timestamp >= deadline_;
    uint leftOverFunds = metGoal ? this.balance - targetFundsWei_  // Rectify
                                 : 0;   
    bool projectEnd = metGoal || atTimeLimit;

    // Send any leftovers back and add contribution 
    sendTo(contributor, leftOverFunds);
    addFundsToContributor(contributorsDB_, contributor, fundsWei - leftOverFunds);

    if (atTimeLimit)
      refund();
    else if (metGoal)
      payout();

    return projectEnd;
  }
  // TODO: End project. selfdestruct etc
  function getProjectInfo () constant
    returns (address fundinghub, address owner, int secondsToDeadline, uint targetFunds, uint totalFunds)
  {
    return (fundhubAddress_, owner_, int(deadline_) - int(now), targetFundsWei_, this.balance);
  }

  // TODO: Account for timezone
  // TODO: Cleanup code

  // ***********************
  // Helper functions
  // Sends all funds received to owner of the project
  function payout() private {
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
  function refund() private {
    mapContributorFunds(contributorsDB_, sendTo);
    // TODO: Put event here stating what was (or wasn't if there is such a bug) sent back
  }

  function sendTo(address recipient, uint bal) private {
    if (bal == 0) return;                // NOTE: Consider optimization of removing this line during a map.
    if (!recipient.send(bal)) throw;
  }

  
  // ***********************
  // Modifiers
  modifier isAddressValid (address addr) {
    if (addr == 0) throw;
    _;
  }

  modifier isEnoughFunds (uint funds) {
    if (funds == 0) throw;
    _;
  }

  modifier isFundingHubAddress (address addr) {
    if (addr != fundhubAddress_) throw;
    _;
  }
  
}
