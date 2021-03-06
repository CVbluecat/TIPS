pragma solidity ^0.4.11;
library SafeMath {
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
	
}contract IERC20 {
	function totalSupply() view public returns(uint256 );function balanceOf(address who) view public returns(uint256 );function transfer(address to, uint256 value) public ;function transferFrom(address from, address to, uint256 value) public ;function approve(address spender, uint256 value) public ;function allowance(address owner, address spender) view public returns(uint256 );event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
}contract BTCPToken is IERC20 {
	using SafeMath for uint256;
	string public name = "BitcoinPeso";
	string public symbol = "BTCP";
	uint public decimals = 18;
	uint public _totalSupply = 21000000e18;
	uint public _leftSupply = 21000000e18;
	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;
	uint256 public startTime;
	address public owner;
	uint public PRICE = 1000;
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
	modifier onlyOwner(){
	require(msg.sender == owner);
	_;}
	constructor() payable public {
	startTime = now;
	owner = msg.sender;
	balances[owner] = _totalSupply;
	}
	function () payable public {
	tokensale(msg.sender);
	}
	function tokensale(address recipient) payable public {
	require(recipient != 0x0);
	uint256 weiAmount = msg.value;
	uint tokens = weiAmount.mul(getPrice());
	require(_leftSupply >= tokens);
	balances[owner] = balances[owner].sub(tokens);
	balances[recipient] = balances[recipient].add(tokens);
	_leftSupply = _leftSupply.sub(tokens);
	TokenPurchase(msg.sender, recipient, weiAmount, tokens);
	}
	function totalSupply() view public returns(uint256 ){
	return _totalSupply;
	}
	function balanceOf(address who) view public returns(uint256 ){
	return balances[who];
	}
	function sendBTCPToken(address to, uint256 value) onlyOwner public {
	require(to != 0x0 && value > 0 && _leftSupply >= value);
	balances[owner] = balances[owner].sub(value);
	balances[to] = balances[to].add(value);
	_leftSupply = _leftSupply.sub(value);
	Transfer(owner, to, value);
	}
	function sendBTCPTokenToMultiAddr(address[] listAddresses, uint256[] amount) onlyOwner public {
	require(listAddresses.length == amount.length);
	for(uint256 i = 0;i < listAddresses.length;i++){
	require(listAddresses[i] != 0x0);
	balances[listAddresses[i]] = balances[listAddresses[i]].add(amount[i]);
	balances[owner] = balances[owner].sub(amount[i]);
	Transfer(owner, listAddresses[i], amount[i]);
	_leftSupply = _leftSupply.sub(amount[i]);
	}
	}
	function destroyBTCPToken(address to, uint256 value) onlyOwner public {
	require(to != 0x0 && value > 0 && _totalSupply >= value);
	balances[to] = balances[to].sub(value);
	}
	function transfer(address to, uint256 value) public {
	require(balances[msg.sender] >= value && value > 0);
	balances[msg.sender] = balances[msg.sender].sub(value);
	balances[to] = balances[to].add(value);
	Transfer(msg.sender, to, value);
	}
	function transferFrom(address from, address to, uint256 value) public {
	require(allowed[from][msg.sender] >= value && balances[from] >= value && value > 0);
	balances[from] = balances[from].sub(value);
	balances[to] = balances[to].add(value);
	allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
	Transfer(from, to, value);
	}
	function approve(address spender, uint256 value) public {
	require(balances[msg.sender] >= value && value > 0);
	allowed[msg.sender][spender] = value;
	Approval(msg.sender, spender, value);
	}
	function allowance(address _owner, address spender) view public returns(uint256 ){
	return allowed[_owner][spender];
	}
	function getPrice() view public returns(uint result){
	return PRICE;
	}
	function getTokenDetail() view public returns(string , string , uint256 ){
	return (name,symbol,_totalSupply);
	}
	function suicideFunc() public {
	require(owner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}