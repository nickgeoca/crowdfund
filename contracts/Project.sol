pragma solidity 0.4.6;

import "Set.sol";

// TODO: Put Project in own file 

// TODO: What to do after payout/refund?
// a Leave Project as is
// b Kill Project
// c Delete mappings

contract Project {
  using Set for *;

  // *******************
  //      Storage
  uint private deadline_;
  uint private targetFundsWei_;
  address private owner_;
  address private fundhubAddress_;
  Set.Data private contributorsDB_;

  
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
    uint contributorsCurrentFunding = Set.get(contributorsDB_, contributor);

    // Send any leftovers back and add contribution 
    sendTo(contributor, leftOverFunds);
    Set.insert( contributorsDB_
              , contributor
              , contributorsCurrentFunding + fundsWei - leftOverFunds);

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
    suicide(owner_);
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
    Set.map(contributorsDB_, sendToUnsafe);
    suicide(owner_);
  }

  function sendTo(address recipient, uint bal) private {
    if (bal == 0) return;                // NOTE: Consider optimization of removing this line during a map.
    if (!recipient.send(bal)) throw;
  }

  function sendToUnsafe(address recipient, uint bal) private {
    recipient.send(bal);
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
