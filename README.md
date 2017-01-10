[https://github.com/nickgeoca/crowdfund](https://github.com/nickgeoca/crowdfund)

# Crowdfunding - Ethereum
### B9Lab Final Project
This is a crowdfunding smart contract and interface that uses Ethereum. Similarly to Kickstarter, it works as follows:
 * A project has an end date, target funding, and an owner. It is created through the FundHub contract.
 * A person (contributor) can fund a project.
 * If the project target funding is met, the funds from the contributor go to the project owner. With the following exception:
 * If the project's end date is over, all funds are returned to the contributors. 
 * Everyone creates and interacts with the project through the designated FundHub contract.

### Trouble Shooting
 * **Project refunding stage**: The projects don't automatically give the funds back to contributors (refund). One must make a contribution, which also gets refunded. The project contract is not event driven and relies on it being executed.

### Tech Stack
This project uses:
 * Truffle- for project build, contract deployment, and testing
 * Solidity- Smart contracts
 * Angular JS- Interface 

### Running the code
#### Deploy the FundHub contract
 * cd project-folder
 * truffle deploy

#### Test script
 * cd project-folder
 * testrpc -a 3  # Terminal 1
 * truffle test  # Terminal 2

#### Build the interface
 * cd project-folder
 * truffle build

### TODO
There is a todo list in the code. This can be seen by running (replace "path to project"): grep -rnw 'PATH TO Project' -e "TODO" . Here are some examples of needed updates.
 * Changing the code to use UTC time instead of local time, etc.
 * More test. Right now it tests mainly for refunding.
