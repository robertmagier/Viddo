pragma solidity ^0.4.17;


import "./DetailedERC20.sol";
import "./StandardToken.sol";
import "./BurnableToken.sol";
import "./Ownable.sol";

contract ViddoToken is StandardToken, BurnableToken, Ownable ,DetailedERC20 {

  constructor () DetailedERC20("VIDDOToken","VDT",0) public
  {
    totalSupply_ = 100 * 10**6;
    balances[msg.sender] = totalSupply_;
    emit Transfer(0x0,msg.sender,totalSupply_);
  }

}
