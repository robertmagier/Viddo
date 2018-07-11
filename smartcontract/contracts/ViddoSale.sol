pragma solidity ^0.4.24;


import "./Crowdsale.sol";
import "./WhitelistedCrowdsale.sol";

/*
@title viddoSale
@author Robert Magier robert.magier@gmail.com
@notice This contract is used to sell tokens from ViddoToken conntract. It has different tokenamount calculation. It also sends unused ETH back. token amount is calculcate by dividing wei amount by token price. Unused ETH is send back.

*/

contract ViddoSale is Crowdsale,WhitelistedCrowdsale{

  event SelfDestruct(address wallet);
  bool paused = false;

  /// @author Robert Magier
  /// @notice ViddoSale contract constructor. Initiate open zeppelin parent Crowdsale contract. Nothing more.
  /// @param _rate Initial token price
  /// @param _wallet Ethereum account address where all funds from token sale will be transfered. This address is also used when contract is destroyed.
  /// @param _token Token address which will be sold by this contract. Viddo Sale contract must have some tokens for sale.

  constructor (uint _rate,address _wallet,address _token) Crowdsale(_rate,_wallet,ERC20(_token)) public
  {

  }
  /// @author Robert Magier
  /// @notice Calculate amount of tokens. wei amount is divided by token price.
  /// @dev this is internal function
  /// @param _weiAmount Amount of wei which was send to buy tokens
  /// @return calculated amount of tokens which have to be transfered in this transaction.

  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256)
  {
    return _weiAmount.div(rate);
  }

  /// @author Robert Magier
  /// @notice This internal functionality
  /// @dev this is internal function which describe how to process purchase. Can be called only when contract is not paused. This means it will be impossible to buy tokens if this contract is paused.
  /// @param _beneficiary Ethereum account address which will receive tokens.
  /// @param _tokenAmount Amount of tokens which must be transfered to beneficiary
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) ifNotPaused internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);

  }

  /// @author Robert Magier
  /// @notice This function will destroy token and free storage on blokchcina. All remaining funds and tokens will be transfered to wallet address.
  /// @dev This function can only be called by contract owner.
  function destroy() public onlyOwner
  {
    require (wallet != 0x0);
    token.transfer(wallet,token.balanceOf(this));
    emit SelfDestruct(wallet);
    selfdestruct(wallet);

  }

  /// @author Robert Magier
  /// @notice Changes value of private variable paused. If paused == true then it is not possible to buy tokens.
  /// @return _paused Boolean variable. It is true if contract was paused.
  /// @dev only contract owner can call this funcion.
  function Pause() public onlyOwner returns(bool _paused)
  {
    paused = true;
    return true;
  }
  /// @author Robert Magier
  /// @notice Changes value of private variable paused. If paused == false then IT IS  possible to buy tokens.
  /// @return _paused Boolean variable. It is false if contract was unpaused.
  /// @dev only contract owner can call this funcion.

  function UnPause() public onlyOwner returns(bool _paused)
  {
    paused = false;
    return false;
  }


  /// @author Robert Magier
  /// @notice It is modifier which allows to run code only when contract IS NOT paused.

  modifier ifNotPaused() {
    require(paused == false);
    _;
  }


  /// @author Robert Magier
  /// @notice Changee token price. This function can be called only by contract owner.
  /// @param _rateInWei New token price. Amount of token for sale is calculated as a division of wei amount by rate
  /// @dev new _rateInWei must be bigger than zero. It is not possible to set token price to zero. Pause sale instead of setting price to zero.

  function setRate(uint256 _rateInWei) public onlyOwner returns(bool)
  {
    require (_rateInWei > 0);
    rate = _rateInWei;
  }

}
