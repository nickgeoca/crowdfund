pragma solidity ^0.4.6;

import "Project.sol";


// TODO:  In Truffle, create a migration script that calls the createProject function after FundingHub has been deployed.

contract FundingHub {
  // ******************
  //      Types
  // Iterable map. Add only. Unique addresses.
  struct ProjectDB {
    mapping (address => Project) nameToProject;
    address[] addressesIndexed;
  }

  function insertProjectDB (ProjectDB storage db, address key, Project p) private {
    db.nameToProject[key] = p;
    db.addressesIndexed.push(key);
  }

  function getProjectDB (ProjectDB storage db, address key) private returns (Project) {
    return db.nameToProject[key];
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

    Project project = getProjectDB(projectAddress);

    insertProjectDB(projectDB_, projectAddress, project);

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

    if (project.exists())
      project.fund(contributor, msg.value);

    return project.exists();
  }

  // *****************
  // Private functions
  function toUnixTime(uint bcTimestamp) private returns (uint) {
    return bcTimestamp + diff_UnixTime_BCTime_;    
  }

  function toBCTime(uint unixTimestamp) private returns (uint) {
    return unixTimestamp - diff_UnixTime_BCTime_;
  }

  modifier isAddressValid (address recipient) {
    if (recipient == 0) throw;
    _;
  }
}
