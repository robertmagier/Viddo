# Viddo

This is Smart Contract and Documentation for Viddo Token.
Smart Contract is implemented using Truffle FrameWork.

# Author
Robert Magier - robert.magier@gmail.com

# Functionality
* ERC20 Standard Token
* Burnable: Yes
* Mintable: No
* Pausable: No
* Name: VIDDOtoken
* Symbol: VDT
* Decimals: 0
* Total supply: 100 000 000 (100 \* 10 \*\* 6)


# Remix http://remix.ethereum.org
To compile and deploy this contract from Remix it is best to first create flat file. Flat file can be generated in smart contract direcotry using command:

**truffle-flattener .\contracts\ViddoToken.sol**

To install run command: **npm install -g truffle-flattener**

You have to use Flat file to run code verification process on etherscan.io and also to be able to debug your smartcontract in remix. 
Truffle allows to compile, migrate and test smartcontract which import another files ( multifile smartcontract ), but it is not yet possible in Remix and Etherscan.io
