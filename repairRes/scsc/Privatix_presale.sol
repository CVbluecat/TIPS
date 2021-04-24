pragma solidity ^0.4.11;
contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) view public returns(uint256 );function transfer(address to, uint256 value) public returns(bool );event Transfer(address indexed from, address indexed to, uint256 value);
	
}contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) view public returns(uint256 );function transferFrom(address from, address to, uint256 value) public returns(bool );function approve(address spender, uint256 value) public returns(bool );event Approval(address indexed owner, address indexed spender, uint256 value);
	
}contract BasicToken is ERC20Basic {
	using SafeMath for uint256;
	mapping(address => uint256) balances;
	function transfer(address _to, uint256 _value) public returns(bool ){
	balances[msg.sender] = balances[msg.sender].sub(_value);
	balances[_to] = balances[_to].add(_value);
	Transfer(msg.sender, _to, _value);
	return true;
	}
	function balanceOf(address _owner) view public returns(uint256 balance){
	return balances[_owner];
	}
	
}contract Crowdsale {
	using SafeMath for uint256;
	MintableToken public token;
	uint256 public startBlock;
	uint256 public endBlock;
	address public wallet;
	uint256 public rate;
	uint256 public weiRaised;
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
	constructor(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet) public {
	require(_startBlock >= block.number);
	require(_endBlock >= _startBlock);
	require(_rate > 0);
	require(_wallet != 0x0);
	token = createTokenContract();
	startBlock = _startBlock;
	endBlock = _endBlock;
	rate = _rate;
	wallet = _wallet;
	}
	function createTokenContract() internal returns(MintableToken ){
	return new MintableToken();
	}
	function () payable public {
	buyTokens(msg.sender);
	}
	function buyTokens(address beneficiary) payable public {
	require(beneficiary != 0x0);
	require(validPurchase());
	uint256 weiAmount = msg.value;
	uint256 tokens = weiAmount.mul(rate);
	weiRaised = weiRaised.add(weiAmount);
	if(! token.mint(beneficiary, tokens)){
	throw;}
	TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
	forwardFunds();
	}
	function forwardFunds() internal {
	wallet.transfer(msg.value);
	}
	function validPurchase() view internal returns(bool ){
	uint256 current = block.number;
	bool withinPeriod = current >= startBlock && current <= endBlock;
	bool nonZeroPurchase = msg.value != 0;
	return withinPeriod && nonZeroPurchase;
	}
	function hasEnded() view public returns(bool ){
	return block.number > endBlock;
	}
	
}contract StandardToken is ERC20 , BasicToken {
	mapping(address => mapping(address => uint256)) allowed;
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool ){
	var _allowance = allowed[_from][msg.sender];
	balances[_to] = balances[_to].add(_value);
	balances[_from] = balances[_from].sub(_value);
	allowed[_from][msg.sender] = _allowance.sub(_value);
	Transfer(_from, _to, _value);
	return true;
	}
	function approve(address _spender, uint256 _value) public returns(bool ){
	require((_value == 0) || (allowed[msg.sender][_spender] == 0));
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint256 remaining){
	return allowed[_owner][_spender];
	}
	
}contract Ownable {
	address public owner;
	constructor() public {
	owner = msg.sender;
	}
	modifier onlyOwner(){
	require(msg.sender == owner);
	_;}
	function transferOwnership(address newOwner) onlyOwner public {
	if(newOwner != address(0)){
	owner = newOwner;
	}
	}
	
}contract MintableToken is StandardToken , Ownable {
	event Mint(address indexed to, uint256 amount);
	event MintFinished();
	bool public mintingFinished = false;
	modifier canMint(){
	require(! mintingFinished);
	_;}
	function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool ){
	totalSupply = totalSupply.add(_amount);
	balances[_to] = balances[_to].add(_amount);
	Mint(_to, _amount);
	return true;
	}
	function finishMinting() onlyOwner public returns(bool ){
	mintingFinished = true;
	MintFinished();
	return true;
	}
	
}library SafeMath {
	function mul(uint256 a, uint256 b) view internal returns(uint256 ){
	uint256 c = a * b;
	assert(a == 0 || c / a == b);
	return c;
	}
	function div(uint256 a, uint256 b) view internal returns(uint256 ){
	uint256 c = a / b;
	return c;
	}
	function sub(uint256 a, uint256 b) view internal returns(uint256 ){
	assert(b <= a);
	return a - b;
	}
	function add(uint256 a, uint256 b) view internal returns(uint256 ){
	uint256 c = a + b;
	assert(c >= a);
	return c;
	}
	
}contract HodboToken is MintableToken {
	string public name = "HODBO TOKEN";
	string public symbol = "HCN";
	uint256 public decimals = 18;
	
}contract HodboCrowdsale is Crowdsale {
	constructor() Crowdsale(4155896,4355866,230,0x21aA5432BB218f49d46B442749Bc69Adad36Fd16) public {
	}
	function createTokenContract() internal returns(MintableToken ){
	return new HodboToken();
	}
	
}