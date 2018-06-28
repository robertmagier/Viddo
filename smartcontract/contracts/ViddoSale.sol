pragma solidity ^0.4.17;


import "./Crowdsale.sol";
import "./WhitelistedCrowdsale.sol";

contract ViddoSale is Crowdsale,WhitelistedCrowdsale{

  constructor (uint _rate,address _wallet,address _token) Crowdsale(_rate,_wallet,ERC20(_token)) public
  {

  }
  function _gsetTokenAmount(uint256 _weiAmount)   internal view returns (uint256)
  {
    return 1;
  }

}
