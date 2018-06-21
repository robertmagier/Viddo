pragma solidity ^0.4.17;


import "./Crowdsale.sol";

contract ViddoSale is Crowdsale {

  constructor (uint _rate,address _wallet,address _token) Crowdsale(_rate,_wallet,ERC20(_token)) public
  {

  }

}
