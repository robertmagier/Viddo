pragma solidity ^0.4.17;


import "./DetailedERC20.sol";
import "./StandardToken.sol";
import "./BurnableToken.sol";

contract ViddoToken is StandardToken, BurnableToken ,DetailedERC20 {

  constructor () DetailedERC20("VIDDOtoken","VDT",0) public
  {
    totalSupply_ = 100 * 10**6;
  }

}
