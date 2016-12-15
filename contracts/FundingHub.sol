pragma solidity ^0.4.6;

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

  // TODO: Remove project if refund/payout from DS?

  // *******************
  //    Constructor
  function FundingHub(uint currentTimeUnixTimestamp) {
    if (currentTimeUnixTimestamp < block.timestamp) throw; // NOTE: Could cause problems way in future
    diff_UnixTime_BCTime_ = int(currentTimeUnixTimestamp) - int(block.timestamp);
  }
  
  // *******************
  //      Storage
  ProjectDB private projectDB_;
  int diff_UnixTime_BCTime_;
  
  // *****************
  // Public functions

  // This function:
  //   * allows a user to add a new project to the FundingHub. 
  //   * deploys a new Project contract and keep track of its address.
  //   * accept all constructor values that the Project contract requires.
  function createProject ( string name
                         , address owner
                         , uint targetFundingWei
                         , uint deadlineUnixTimestamp)
                         returns (address) 
  {
    uint deadlineBlockchainTimestamp = toBCTime(deadlineUnixTimestamp);
    address projectAddress = new Project(owner, targetFundingWei, deadlineBlockchainTimestamp);

    Project project = Project(projectAddress);

    insertProjectDB(projectDB_, project);

    return projectAddress;
  }

  // This function
  //  * allows users to contribute to a Project identified by its address
  //  * contribute calls the fund() function in the individual Project contract. All funding passes thru
  function contribute(address projectAddress, address contributor)
    isAddressValid(projectAddress)
    isAddressValid(contributor)
    returns (bool)
  {
    Project project = Project(projectAddress);
    bool isValid = isMemberProjectDB(projectDB_, project);
    bool projectEnd;

    if (!isValid) return isValid;  // TODO: Better naming here?

    projectEnd = project.fund(contributor, msg.value);
    if (projectEnd)
      deleteProjectDB(projectDB_, project);
  }

  // *****************
  // Private functions
  function toUnixTime(uint bcTimestamp) private returns (uint) {
    if (int(bcTimestamp) < diff_UnixTime_BCTime_) throw;
    return uint(int(bcTimestamp) + diff_UnixTime_BCTime_);    
  }

  function toBCTime(uint unixTimestamp) private returns (uint) {
    if (int(unixTimestamp) < diff_UnixTime_BCTime_) throw;
    return uint(int(unixTimestamp) - diff_UnixTime_BCTime_);    
  }

  modifier isAddressValid (address recipient) {
    if (recipient == 0) throw;
    _;
  }
}
