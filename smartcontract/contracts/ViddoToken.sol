pragma solidity ^0.4.24;


import "./DetailedERC20.sol";
import "./StandardToken.sol";
import "./BurnableToken.sol";
import "./Ownable.sol";


/// @author         Robert Magier
/// @title          EmptyReceiver
/// @notice         This is empty token which does nothing. It is used only to create new address which
///                 can be used as received in ViddoToken contract.

contract EmptyReceiver
{

  address private owner;

  constructor () {
    owner = msg.sender;
  }

  /// @author     Robert Magier
  /// @notice     Destroy this contract to free blockchain resources. We only need this address to generate address.
  /// @dev        Anybody can call this function as the only purpose of this contract is to be killed.
  function die () public{
    suicide(owner);
  }
}

/// @title        Viddo Token
/// @author       Robert Magier
/// @notice       Reciver contract is an empty contract. We generate new ReciverContract only to get
///               an address where  ViddoToken must be sent to exchange it for Pro Account.
contract ViddoToken is StandardToken, BurnableToken, Ownable ,DetailedERC20 {

  event NewProAccount(address indexed buyer,address indexed proAccountOwner);
  event NewProReceiver(address indexed creator,address indexed receiver);

  //mapps ethereum address to Pro Account. User can have only one proAccount so it is true or false.
  mapping(address => bool) hasProAccount;

  /// @notice     receiver is an address to which clients can send tokens to exchange them for proAccount.
  //              user can have only one proAccount and receiver can be used only once.
  mapping(address => bool) receivers;

  ///@notice      map receiver address to Account which send token and exchange it for proAccount.
  mapping(address=>address) receiverBenefactor;

  address public saleContract;
  address public burner;

  /// @author     Robert Magier
  /// @notice     Constructor initialize parent contract DetailedERC20 and set some initial values like
  ///             totalSUpply, owner balance and emits Transfer event. Token owner gets all tokens.
  /// @dev        This contstructor set totalSupply and set owner's balance equal to totalSupply.
  ///             This means that owner gets it all.
  constructor () DetailedERC20("VIDDOToken","VDT",0) public
  {
    totalSupply_ = 100 * 10**6;
    balances[msg.sender] = totalSupply_;
    emit Transfer(0x0,msg.sender,totalSupply_);
  }

  /// @author     Robert Magier
  /// @notice     Only Burner Account can execute code within this modifier. Burner is an account which is supposed
  ///             to burn tokens int the Pro Account Buying Process.
  modifier onlyBurner() {
    require (msg.sender == burner);
    _;
  }

  /// @author     Robert Magier
  /// @notice     Set burner account address. Can be executed only by Token owner.
  /// @param      _newburner Account address to set as Burner.
  /// @return     true if successfull
  function SetBurner(address _newburner) onlyOwner returns (bool)
  {
    require(_newburner != 0x0);
    burner = _newburner;
    return true;
  }



  /// @author     Robert Magier
  /// @notice     This function burns token owned by msg.sender and change for proAccount. User can have
  ///             only one proAccount.
  /// @param      beneficiary ethereum account address which will receive Pro Account.  Beneficiary account can have
  ///             only one Pro Account. This is not the same as e-mail address or Viddo.com login name. If user wants to
  ///             have more than one account he simply have to have more ethereum addresses.
  /// @dev        Maybe it should be better to allow to have mor pro account assigned to one ethereum account.
  /// @return     true if successfull
  function BuyProAccount(address beneficiary) onlyBurner returns (bool)
  {
    require(hasProAccount[beneficiary] = false);
    require(balanceOf(msg.sender) > 0);
    burn(1);
    hasProAccount[beneficiary] = true;
    receiverBenefactor[beneficiary] = msg.sender;
    emit NewProAccount(msg.sender,beneficiary);
    return true;
  }


  /// @author     Robert Magier
  /// @notice     When Pro Account is bought by viddo.com page this funcion can be used to burn token and emit
  ///             an event informing that New Pro Account was created. In this case no account address  will
  ///             be associated with Pro Account.
  function BurnForProAccount() onlyBurner returns (bool)
  {
    require (balances[msg.sender] > 0);
    burn(1);
    emit NewProAccount(msg.sender,0x0);
  }


  /// @author     Robert Magier
  /// @notice     Check if address is marked as receiver
  /// @param      _receiver address which is checked to be marked as receiver
  /// @return     True if _receiver is marked as receiver. Otherwise false.
  function  IsReceiver(address _receiver) public view returns(bool)
  {
  return receivers[_receiver];
  }

  /// @author     Robert Magier
  /// @notice     This function adds receiver. Receiver address
  /// @param      _receiver Is the address of new receiver.
  /// @dev        Function check if receiver wasn't added before or is not a valid token owner (owns token/s)
  ///             Receiver can be only added once. Receiver can be added only by token owner.
  function AddReceiver(address _receiver) public onlyOwner
  {
    require(receivers[_receiver] == false);
    require(balanceOf(_receiver)== 0);
    receivers[_receiver] = true;
  }

  ///@author      Robert Magier
  ///@notice      This function removes receiver from the list. Only owner can execute this function and receiver can't
  ///             Pro Account.
  /// @param      _receiver is an address of receiver account to be removed.
  /// @return     true if successfull
  function RemoveReceiver(address _receiver) public onlyOwner returns (bool)
  {
    require(receivers[_receiver] == true);
    require(hasProAccount[_receiver]==false);
    receivers[_receiver] = false;
  }

  /// @author     Robert Magier
  /// @notice     Use this function to see who send token to specific receiving address
  /// @param      _receiver address foro which are returning benefactor address.
  /// @return    Benefactor address.

  function GetReceiverBenefactor(address _receiver) public view returns (address)
  {
    require(receivers[_receiver]);
    return receiverBenefactor[_receiver];
  }

  /// @author     Robert Magier
  /// @notice     This function create new EmptyReceiver contract. Take it's address and set it as receiver.
  ///             Then destroys EmptyReciever contract not trash blockchain.
  /// @return     New receiver address which was just added as receiver.
  /// @dev        If by any chance this function create receiver address which was added before to the contract then
  ///             it will revert. It is highly inlikely but theoritically possible.
function GenerateReceiver() public onlyOwner returns (address)
{
    EmptyReceiver newReceiver = new EmptyReceiver();
    require (receivers[address(newReceiver)]==false);
    require (balanceOf(address(newReceiver)) == 0);

    receivers[address(newReceiver)] = true;
    newReceiver.die();
    return newReceiver;
}


  /// @author     Robert Magier
  /// @notice     Check if receiver address already received token and exchanged it for Pro Account.
  /// @param      receiver address which we check if has received token to buy pro account.
  /// @return     true if receiver  received token. false if not.
function IsReceiverConfirmed (address receiver) public view returns (bool)
{
  return hasProAccount[receiver];
}

  /// @author     Robert Magier
  /// @notice     This is internal function which is called to move token to receiver address.
  /// @dev        This function doesn't check if address is a receiver. Must be done before calling this function.
  /// @param     receiver address to which token should be send and exchange for Pro Account.
  /// @return     True if executed successfully or revert.
function _transferToReceiver(address receiver) internal returns (bool)
{
  require(hasProAccount[receiver] == false);
  _burn(msg.sender,1);
  hasProAccount[receiver] = true;
  receiverBenefactor[receiver] = msg.sender;
  emit NewProAccount(msg.sender,receiver);
  return true;
}

  /// @author   Robert Magier
  /// @notice   This is public ERC20 Standard function. Every ERC20 must implement this function to follow ERC20
  ///           Standard.
  /// @dev      One additional thing which is implemented in this contract is to check if _to address is marked as
  ///           receiver. In this case we burn only one token and exchange it for pro account.
function transfer(address _to, uint256 _value) public returns (bool) {

  require(_value > 0);
  require(_to != address(0));
  if(receivers[_to] == true) return _transferToReceiver(_to);
  require(_value <= balances[msg.sender]);
  balances[msg.sender] = balances[msg.sender].sub(_value);
  balances[_to] = balances[_to].add(_value);
  emit Transfer(msg.sender, _to, _value);
  return true;
}

/// @author   Robert Magier
/// @notice   This is public ERC20 Standard function. Every ERC20 must implement this function to follow ERC20
///           Standard.
/// @dev      One additional thing which is implemented in this contract is to check if _to address is marked as
///           receiver. In this case we burn only one token and exchange it for pro account.
function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
{
  require(_to != address(0));
  require(_value <= allowed[_from][msg.sender]);

  if(receivers[_to] == true) return _transferToReceiver(_to);

  require(_value <= balances[_from]);

  balances[_from] = balances[_from].sub(_value);
  balances[_to] = balances[_to].add(_value);
  allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
  emit Transfer(_from, _to, _value);
  return true;
}



}
