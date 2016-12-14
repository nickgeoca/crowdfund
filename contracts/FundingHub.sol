pragma solidity ^0.4.2;

import "Project.sol";

// FundingHub is the registry of all Projects to be funded. FundingHub should have a constructor and the following functions:

// TODO:  In Truffle, create a migration script that calls the createProject function after FundingHub has been deployed.

contract FundingHub {


  function FundingHub(uint ) {
    
  }

  // ******************
  //      Types
  // Iterable map. Add only. Unique addresses.
  struct ProjectDB {
    mapping (address => Project) nameToProject;
    address[] addressesIndexed;
  }

  function insertProjectDB (ProjectDB db, address key, Project p) private {
    db.nameToProject[key] = p;
    db.namesIndexed.push(key);
  }

  function getProjectDB (ProjectDB db, address key) private returns (Project) {
    return db.nameToProject[key];
  }

  // *******************
  //      Variables
  ProjectDB private projectDB_;
  

  // This function:
  //   * allows a user to add a new project to the FundingHub. 
  //   * deploys a new Project contract and keep track of its address.
  //   * accept all constructor values that the Project contract requires.
  function createProject ( string name
                         , address owner
                         , uint targetFundingWei
                         , uint16 endYear
                         , uint8 endMonth
                         , uint8 endDay
                         , uint8 endHour) returns (address) 
  {
    address projectAddress = new
      Project ( owner
              , targetFundingWei
              , endYear
              , endMonth
              , endDay
              , endHour);
    Project project = Project(projectAddress);

    insertProjectDB(projectDB_, projectAddress, project);

    return projectAddress;
  }

  // This function
  //  * allows users to contribute to a Project identified by its address
  //  * contribute calls the fund() function in the individual Project contract. All funding passes thru
  function contribute(address projectAddress, address contributor)
    isValidAddress(projectAddress)
    isValidAddress(contributor)
    returns (bool)
  {
    Project p = getProjectDB(projectAddress);
    bool projectExist = p.exists()

    if (projectExist)
      p.fund(contributor, msg.value);

    return projectExist;
  }
}
