pragma solidity 0.4.6;

// import "Project.sol";


// TODO:  In Truffle, create a migration script that calls the createProject function after FundingHub has been deployed.

contract FundingHub {
  // ******************
  //      Types

  // Iterable map. Add only. Unique addresses.
  struct ProjectDB {
    mapping (address => uint) addressToIndex;
    address[] indexedAddresses;
  }

  function isMemberProjectDB (ProjectDB storage db, Project project) private returns (bool) {
    address addr = address(project);
    uint index = db.addressToIndex[addr];
    return db.indexedAddresses[index] == addr;
  }

  function insertProjectDB (ProjectDB storage db, Project project) private {
    address addr = address(project);
    uint index = db.indexedAddresses.length;

    db.addressToIndex[addr] = index;
    db.indexedAddresses.push(addr);
  }

  function deleteProjectDB (ProjectDB storage db, Project project) private {
    address removeAddr = address(project);
    uint removeIndex = db.addressToIndex[removeAddr];
    uint keepIndex = db.indexedAddresses.length - 1;
    address keepAddr = db.indexedAddresses[keepIndex];

    if (db.indexedAddresses.length == 0) throw;
    if (!isMemberProjectDB(db, project)) throw;

    // Update index and address's index
    db.addressToIndex[keepAddr] = removeIndex;
    db.indexedAddresses[removeIndex] = keepAddr;

    // TODO: Delete contract here too
    delete db.addressToIndex[removeAddr];
    db.indexedAddresses.length = db.indexedAddresses.length - 1; // TODO: Make sure this works!
  }

  function getProjects_ProjectDB (ProjectDB storage db) private returns (address[]) {
    return db.indexedAddresses;
  }

  // TODO: Remove project if refund/payout from DS?

  // *******************
  //      Storage
  ProjectDB private projectDB_;
  int private diff_UnixTime_BCTime_;

  // *****************
  // Public functions

  //    Constructor
  function FundingHub(uint currentTimeUnixTimestamp) {
    diff_UnixTime_BCTime_ = int(currentTimeUnixTimestamp) - int(block.timestamp);
  }

  // This function:
  //   * allows a user to add a new project to the FundingHub. 
  //   * deploys a new Project contract and keep track of its address.
  //   * accept all constructor values that the Project contract requires.
  function createProject ( address owner
                         , uint targetFundingWei
                         , uint deadlineUnixTimestamp)
                         returns (address)
  // TODO: Check owner is valid address
  {
    uint deadlineBlockchainTimestamp = toBCTime(deadlineUnixTimestamp);
    Project project = new Project(owner, targetFundingWei, deadlineBlockchainTimestamp);

    insertProjectDB(projectDB_, project);

    E_createProject(owner, project);
    return project;
  } event  E_createProject(address projectOwner, address projectAddress); // TODO: Rely on tx address instead of project owner?

  // This function
  //  * allows users to contribute to a Project identified by its address
  //  * contribute calls the fund() function in the individual Project contract. All funding passes thru
  function contribute(address projectAddress, address contributor)
    payable
    isAddressValid(projectAddress)
    isAddressValid(contributor)
    returns (bool contributionSuccessful)
  {
    Project project = Project(projectAddress);
    bool projectIsValid = isMemberProjectDB(projectDB_, project);
    bool projectEnd;

    if (!projectIsValid) return projectIsValid;  // TODO: Better naming here?

    // Send everything to project and let project.fund take care of redistribution 
    projectEnd = project.fund.value(msg.value)(contributor, msg.value);
    if (projectEnd)
      deleteProjectDB(projectDB_, project);

    E_contribute(projectIsValid);
    return projectIsValid;
  } event  E_contribute(bool contributionSuccessful); 

  // TODO: Make this const?
  // 0,0 retreives all
  // 1,10 retreives first 10
  function browse() constant
    returns (address[]) {
    return getProjects_ProjectDB(projectDB_);
  }

  
  // *****************
  // Private functions

  function sendTo(address recipient, uint bal) private {
    if (bal == 0) return;                // NOTE: Consider optimization of removing this line during a map.
    if (!recipient.send(bal)) throw;
  }


  // y = f(x) = x + (y - x)
  function toUnixTime(uint bcTimestamp) private returns (uint) {
    if (int(bcTimestamp) < diff_UnixTime_BCTime_) throw;
    return uint(int(bcTimestamp) + diff_UnixTime_BCTime_);    
  }

  // x = f(y) = y - (y - x)
  function toBCTime(uint unixTimestamp) private returns (uint) {
    if (int(unixTimestamp) < diff_UnixTime_BCTime_) throw;
    return uint(int(unixTimestamp) - diff_UnixTime_BCTime_);    
  }

  modifier isAddressValid (address recipient) {
    if (recipient == 0) throw;
    _;
  }
}
////////////////////////////////////////////////////////
// FundingHub is the registry of all Projects to be funded. FundingHub should have a constructor and the following functions:


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

    if (metGoal)
      payout();
    else if (atTimeLimit)
      refund();

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
    // TODO:   PUT EVENT HERE STATING WHAT WAS/WASN't SEND BACK'; AMEN
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
