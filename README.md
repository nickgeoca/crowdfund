[https://github.com/nickgeoca/crowdfund](https://github.com/nickgeoca/crowdfund)

Feel free to email me with questions/comments at <github-username> at gmail dot com

# Crowdfunding DAPP - Ethereum
### Overview
This is a crowdfunding decentralized app (DAPP) that uses a smart contract to interface Ethereum. Similarly to Kickstarter, it works as follows:
 * A project has an end date, target funding, and an owner. It is created through the FundHub contract.
 * A person (contributor) can fund a project.
 * Project refund/fund logic, in order:
   1) If the project's end date is over, all funds are returned to the contributors
   2) If the project target funding is met, the funds from the contributor go to the project owner
```solidity
    if (atTimeLimit)
      refund();
    else if (metGoal)
      payout();
```
 * Everyone creates and interacts with the project through the designated FundHub contract.

### Trouble Shooting
 * **Project refunding stage**: The projects don't automatically give the funds back to contributors (refund). One must make a contribution, which also gets refunded. The project contract is not event driven and relies on it being executed.

### Tech Stack
This project uses:
 * Truffle- for project build, contract deployment, and testing
 * Solidity- Smart contracts
 * Angular JS- Interface 

### Running the code
To try the DAPP out on a local Ethereum chain use the follwing commands below.
#### Run DAPP- deploy to the blockchain and interact through browser
 1) Setup (**one time only**)
    * Install geth: https://github.com/ethereum/go-ethereum/wiki/Installation-Instructions-for-Ubuntu
    * Initialize local ethereum blockchain
    * Create new blockchain address and give it a password. Remember this password!
    * Install php server to serve DAPP files
```shell
curl https://raw.githubusercontent.com/nickgeoca/crowdfund/master/genesis42.json > ~/Documents/genesis42.json
geth --datadir ~/.ethereum/net42 init ~/Documents/genesis42.json
geth account new
sudo apt-get install php5
```
 2) Run this once during each programming session
    * Startup local blockchain in console and start mining (**in a seperate terminal**)
```shell
geth --datadir ~/.ethereum/net42 --networkid 42 --rpc --rpcport 8545 --rpcaddr 0.0.0.0 --rpccorsdomain "*" --rpcapi "eth,web3,personal" console
# Start mining the blockchain
miner.start(1)
```
 3) **This command must be run periodically in geth console**
```shell
personal.unlock(personal.listAccounts[0])
```
 4) Deploy smart contract to blockchain once. Or use this if made changes to contract. See part 3 if account is locked
```shell
cd crowdfund
truffle deploy
```
 5) Build js interface
```shell
cd crowdfund
truffle build --reset
```
6) Startup a server in build folder- using php here (**in a seperate terminal**)
```shell
cd crowdfund/build
php -S 0.0.0.0:8000
```
7) Try DAPP out. 
   * Type localhost:8000 in browser. This is the DAPP interface. 
   * Open the console for message logs.
   * Don't forget to unlock the account if it is locked (as in part 3)
   * **Start a project**
   * **Contribute to a project**
   * **Browse projects**. Browsings project addresses are listed in console.
#### Run the contract test
```shell
cd crowdfund
testrpc -a 3  # Terminal 1
truffle test  # Terminal 2
```


### TODO
There is a todo list in the code. This can be seen by running (replace "path to project"): grep -rnw 'PATH TO Project' -e "TODO" . Here are some examples of needed updates.
 * Changing the code to use UTC time instead of local time, etc.
 * More test. Right now it tests mainly for refunding.
