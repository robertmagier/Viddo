pragma solidity ^0.4.24;

// File: contracts\ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts\BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: contracts\BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

// File: contracts\ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts\DetailedERC20.sol

/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

// File: contracts\Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts\StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts\ViddoToken.sol

/// @author         Robert Magier
/// @title          EmptyReceiver
/// @notice         This is empty token which does nothing. It is used only to create new address which
///                 can be used as received in ViddoToken contract.

contract EmptyReceiver
{

  address private owner;

  constructor  () public {
    owner = msg.sender;
  }

  /// @author     Robert Magier
  /// @notice     Destroy this contract to free blockchain resources. We only need this address to generate address.
  /// @dev        Anybody can call this function as the only purpose of this contract is to be killed.
  function die () public{
    selfdestruct(owner);
  }
}

/// @title        Viddo Token
/// @author       Robert Magier
/// @notice       Reciver contract is an empty contract. We generate new ReciverContract only to get
///               an address where  ViddoToken must be sent to exchange it for Pro Account.
contract ViddoToken is StandardToken, BurnableToken, Ownable ,DetailedERC20 {

  /* function GenerateReceiver() public onlyOwner returns (EmptyReceiver); */

  /// @dev This parameter is used to store list of addresses which are allowed to receive tokens.
  mapping(address => bool) public whitelist;

  /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary] || receivers[_beneficiary]); // beneficiary must either on whitelist or be receiver
    _;
  }


    /**
     * @dev Adds single address to whitelist.
     * @param _beneficiary Address to be added to the whitelist
     */
    function addToWhitelist(address _beneficiary) external onlyOwner {
      whitelist[_beneficiary] = true;
    }

    /**
     * @dev Return list of bool informing if user is on the whitelist or not.
     * @param _list list of addresses to check if they are on the whitelist. 
     */
    function areWhiteListed(address [] _list) returns(bool [])
    {
      require (_list.length > 0);
      bool [] results;
      for (uint256 i = 0; i < _list.length; i++) {
        results.push(whitelist[_list[i]]);
      }

      return results;
    }
    /**
     * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
     * @param _beneficiaries Addresses to be added to the whitelist
     */
    function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
      for (uint256 i = 0; i < _beneficiaries.length; i++) {
        whitelist[_beneficiaries[i]] = true;
      }
    }
    /**
     * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
     * @param _beneficiaries Addresses to be added to the whitelist
     */
    function removeManyFromWhitelist(address[] _beneficiaries) external onlyOwner {
      for (uint256 i = 0; i < _beneficiaries.length; i++) {
        whitelist[_beneficiaries[i]] = false;
      }
    }

    /**
     * @dev Removes single address from whitelist.
     * @param _beneficiary Address to be removed to the whitelist
     */
    function removeFromWhitelist(address _beneficiary) external onlyOwner {
      whitelist[_beneficiary] = false;
    }



  /// @dev Last Receiver is only used for testig purpose because web3 library doesn't allow to read values by state changin transaction. Truffle test framework doesn't also read events. The proper way to read last Receiver value is to read NewProReceiver event value.
  address public lastReceiver;
  event NewProAccount(address indexed buyer,address indexed proAccountOwner,uint accountsNumber);
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
    lastReceiver = this;
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
  function SetBurner(address _newburner) public onlyOwner returns (bool)
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
  function BuyProAccount(address beneficiary) public onlyBurner returns (bool)
  {
    require(hasProAccount[beneficiary] == false);
    require(balanceOf(msg.sender) > 0);
    burn(1);
    hasProAccount[beneficiary] = true;
    receiverBenefactor[beneficiary] = msg.sender;
    emit NewProAccount(msg.sender,beneficiary,1);
    return true;
  }

  /// @author     Robert Magier
  /// @notice     When Pro Account is bought by viddo.com page this funcion can be used to burn token and emit
  ///             an event informing that New Pro Account was created. In this case no account address  will
  ///             be associated with Pro Account.
  function BurnForProAccount(uint _number) public onlyBurner returns (bool)
  {
    require (balances[msg.sender] >= _number);
    burn(_number);
    emit NewProAccount(msg.sender,0x0,_number);
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
function GenerateReceiver() public onlyOwner returns (EmptyReceiver)
{
    address newReceiver = address(new EmptyReceiver());
    require (receivers[newReceiver]==false);
    require (balanceOf(newReceiver) == 0);

    receivers[newReceiver] = true;
    /* EmptyReceiver(newReceiver).die(); */

    emit NewProReceiver(msg.sender,newReceiver);
    lastReceiver = newReceiver;
    return EmptyReceiver(newReceiver);

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
  emit NewProAccount(msg.sender,receiver,1);
  return true;
}

  /// @author   Robert Magier
  /// @notice   Transfer token from account to many accounts.
  ///           If transaction to one of those accounts fail then all set fails
  /// @dev      Make sure that both arrays have equal length. In other case this transaction will fail.
  ///           If one transfer fails all will fail. Transfer can fail if you doin't have enough tokens. If you transfer
  ///           to receiver in this transaction then only one token will be used.
function transferToMany(address[] _beneficiaries, uint[] _values) public
{
  require(_beneficiaries.length == _values.length);
  for (uint256 i = 0; i < _beneficiaries.length; i++) {
    transfer (_beneficiaries[i],_values[i]);
  }
}


  /// @author   Robert Magier
  /// @notice   This is public ERC20 Standard function. Every ERC20 must implement this function to follow ERC20
  ///           Standard.
  /// @dev      One additional thing which is implemented in this contract is to check if _to address is marked as
  ///           receiver. In this case we burn only one token and exchange it for pro account.
function transfer(address _to, uint256 _value) public isWhitelisted(_to) returns (bool) {

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
