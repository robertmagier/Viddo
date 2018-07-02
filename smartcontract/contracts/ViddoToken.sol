pragma solidity ^0.4.17;


import "./DetailedERC20.sol";
import "./StandardToken.sol";
import "./BurnableToken.sol";
import "./Ownable.sol";

// Docmentation Example
/**
@title Viddo Token
@author Robert Magier
*/

contract ViddoToken is StandardToken, BurnableToken, Ownable ,DetailedERC20 {

  event BurnTokenforPro(uint256 amount);
  
  mapping(address => uint256) proAccounts;
  address saleContract;


  constructor () DetailedERC20("VIDDOToken","VDT",0) public
  {
    totalSupply_ = 100 * 10**6;
    balances[msg.sender] = totalSupply_;
    emit Transfer(0x0,msg.sender,totalSupply_);
  }


  function BuyProAccount(uint8 number) returns (bool)
  {
    revert();
  }




  function GetAccountsNumber(address _owner) returns (uint256)
  {
    return 0;
  }



}
