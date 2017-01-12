pragma solidity 0.4.6;

import "Project.sol";


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

