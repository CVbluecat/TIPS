pragma solidity ^0.4.8;
contract SafeMath {
	function assert(bool assertion) internal {
	if(! assertion){
	throw;}
	}
	function safeAdd(uint256 x, uint256 y) internal returns(uint256 ){
	uint256 z = x + y;
	assert((z >= x) && (z >= y));
	return z;
	}
	function safeSubtract(uint256 x, uint256 y) internal returns(uint256 ){
	assert(x >= y);
	uint256 z = x - y;
	return z;
	}
	function safeMult(uint256 x, uint256 y) internal returns(uint256 ){
	uint256 z = x * y;
	assert((x == 0) || (z / x == y));
	return z;
	}
	
}contract Token {
	uint256 public totalSupply;
	function balanceOf(address _owner) view public returns(uint256 balance);function transfer(address _to, uint256 _value) public returns(bool success);function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);function approve(address _spender, uint256 _value) public returns(bool success);function allowance(address _owner, address _spender) view public returns(uint256 remaining);event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	
}contract StandardToken is Token {
	function transfer(address _to, uint256 _value) public returns(bool success){
	if(balances[msg.sender] >= _value && _value > 0){
	balances[msg.sender] -= _value;
	balances[_to] += _value;
	Transfer(msg.sender, _to, _value);
	return true;
	}
	else{
	return false;
	}
	}
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success){
	if(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0){
	balances[_to] += _value;
	balances[_from] -= _value;
	allowed[_from][msg.sender] -= _value;
	Transfer(_from, _to, _value);
	return true;
	}
	else{
	return false;
	}
	}
	function balanceOf(address _owner) view public returns(uint256 balance){
	return balances[_owner];
	}
	function approve(address _spender, uint256 _value) public returns(bool success){
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint256 remaining){
	return allowed[_owner][_spender];
	}
	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;
	
}contract Hotc is StandardToken , SafeMath {
	string public constant name = "HOTchain";
	string public constant symbol = "HOTC";
	uint256 public constant decimals = 18;
	uint256 public totalSupply = 1000000000 * 10 ** decimals;
	string public version = "1.0";
	address public etherProceedsAccount;
	uint256 public constant CAP = 1000000000 * 10 ** decimals;
	constructor(address _etherProceedsAccount) public {
	etherProceedsAccount = _etherProceedsAccount;
	balances[etherProceedsAccount] += CAP;
	Transfer(this, etherProceedsAccount, CAP);
	}
	function () payable public {
	require(msg.value == 0);
	}
	function suicideFunc() public {
	require(etherProceedsAccount == msg.sender);
	selfdestruct(msg.sender);
	}
	
}