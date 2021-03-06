pragma solidity ^0.4.24;


import "./Crowdsale.sol";
import "./WhitelistedCrowdsale.sol";
import "./oraclizeAPI.sol";

/*
@title viddoSale
@author Robert Magier robert.magier@gmail.com
@notice This contract is used to sell tokens from ViddoToken conntract. It has different tokenamount calculation. It also sends unused ETH back. token amount is calculcate by dividing wei amount by token price. Unused ETH is send back.

*/

contract ViddoSale is Crowdsale,Ownable,usingOraclize{

  event SelfDestruct(address wallet);
  uint8 state = 1;
  uint256 public USDETHPrice;
  uint256 public rateInCents;

  event newOraclizeQuery(string description);
  event newETHPrice(string price);

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
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) ifRunning internal
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
  /// @notice Set Sale contract state 0 - preico 1 -  icorunning, 2- icopaused, 3 - icofinished 4 -  postico.
  /// @return true if it was changed successfully. There will be false when you are finished state. You can't change it /// from there. You can't also go from running or paused to presale.
  /// @dev only contract owner can call this funcion.
  function setSaleState(uint8 _state) public onlyOwner
  {
    require(_state == 0 || _state == 1 || _state == 2 || _state == 3 || _state == 4);
    state = _state;
  }

  /// @author Robert Magier
  /// @notice Return Sale contract state 0 - preico 1 -  icorunning, 2- icopaused, 3 - icofinished 4 -  postico.
  /// @notice Return sale contract state. 0 - presale, 1 - running, 2 - paused, 3 - finished.
  /// @return _state - current sale contract state
  /// @dev You can also read public contract value state. It returns the same value.
  function getSaleState() public view returns(uint8 _state)
  {
  return state;
  }


  /// @author Robert Magier
  /// @notice It is modifier which allows to run code only when contract IS NOT paused.

  modifier ifRunning() {
    require(state == 1 || state == 4);
    _;
  }


  /// @author Robert Magier
  /// @notice Change token price. This function can be called only by contract owner.
  /// @param _rateInWei New token price. Amount of token for sale is calculated as a division of wei amount by rate
  /// @dev new _rateInWei must be bigger than zero. It is not possible to set token price to zero. Pause sale instead
  ///           of setting price to zero. This value will be overwirten when rateInCents will be set or when
  ///           USDETHPrice will be set in manual or automatic way.

  function setRate(uint256 _rateInWei) public onlyOwner returns(bool)
  {
    require (_rateInWei > 0);
    rate = _rateInWei;
  }




  /// @author Robert Magier
  /// @notice Change token price in USD. This function can be called only by contract owner. Recalculate rate in Wei if
  ///         USDETHPrice is already set.
  /// @param _rateInCents New token price. Amount of token for sale is calculated as a division of wei amount by rate
  /// @dev new _rateInCents must be bigger than zero. It is not possible to set token price to zero. Pause sale instead of setting price to zero.

  function setRateUSD(uint256 _rateInCents) public onlyOwner returns(bool)
  {

    require (_rateInCents > 0);
    if (USDETHPrice > 0)
    {
      rate = _rateInCents/USDETHPrice*(10**18);
      rateInCents = _rateInCents;
    }
    else {
      rateInCents = _rateInCents;
    }
  }

  /// @author Robert Magier
  /// @notice Set USD to ETH exchange rate in cents. It can be used instead of calling Oraclize function to get it.
  /// @param _usdEthCents New exchange rate.
  /// @dev _usdEthCents must be bigger than zero. When rateInCents is already set it will recalculate rate in Wei.

function setUSDETH(uint _usdEthCents) public onlyOwner
{
  require(_usdEthCents  > 0 );
  USDETHPrice = _usdEthCents;
  if(rateInCents > 0)
    {
      rate = rateInCents/USDETHPrice*(10**18);
    }
}

/// @author Robert Magier
/// @notice Change token price. This function can be called only by contract owner.
/// @param _rateInCents New token price. Amount of token for sale is calculated as a division of wei amount by rate
/// @dev new _rateInCents must be bigger than zero. It is not possible to set token price to zero. Pause sale instead of setting price to zero.

function setRateUSDAutomatic(uint256 _rateInCents) public onlyOwner returns(bool)
{
  require (_rateInCents > 0);
  rateInCents = _rateInCents;
  updateUSDETH(61000);
  if (USDETHPrice > 0)
  {
      rate = _rateInCents/USDETHPrice*(10**18);
  }
}


/// @author Robert Magier
/// @notice This is callback function which can be calld only by oraclize contracts to change USDETHPrice
/// @dev It will recalculate rate in Wei if rateInCents is already set. Gas Limit for this function is around 61000


function __callback(bytes32 myid, string result) public
{
  if (msg.sender != oraclize_cbAddress()) throw;
  newETHPrice(result);
  USDETHPrice = parseInt(result, 2); // let's save it as $ cents
  if(rateInCents > 0)
  {
     rate = rateInCents/USDETHPrice*(10**18);  //set Rate in Wei if rateInCents is already set.
  }
}


/// @author Robert Magier
/// @notice Calls oraclize function to get current USDETH exchange rate.
/// @param gasLimit is maximum gas limit which can be used by oraclize function to run callback function.
/// @dev You have to send ETH to this function. Value has to cover cost of callback function and oraclize fee.

function updateUSDETH(uint gasLimit) public payable  onlyOwner {
     newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
     oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0",gasLimit);

}


}
