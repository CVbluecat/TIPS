pragma solidity ^0.4.17;
library SafeMath {
	function sub(uint a, uint b) pure internal returns(uint ){
	assert(b <= a);
	return a - b;
	}
	function add(uint a, uint b) pure internal returns(uint ){
	uint c = a + b;
	assert(c >= a);
	return c;
	}
	
}contract ERC20Basic {
	uint public totalSupply;
	address public owner;
	function balanceOf(address who) view public returns(uint );function transfer(address to, uint value) public ;event Transfer(address indexed from, address indexed to, uint value);
	
}contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) view public returns(uint );function transferFrom(address from, address to, uint value) public ;function approve(address spender, uint value) public ;event Approval(address indexed owner, address indexed spender, uint value);
	
}contract BasicToken is ERC20Basic {
	using SafeMath for uint;
	mapping(address => uint) balances;
	modifier onlyPayloadSize(uint size){
	assert(msg.data.length >= size + 4);
	_;}
	function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public {
	balances[msg.sender] = balances[msg.sender].sub(_value);
	if(_to == address(this)){
	balances[owner] = balances[owner].add(_value);
	Transfer(msg.sender, owner, _value);
	}
	else{
	balances[_to] = balances[_to].add(_value);
	Transfer(msg.sender, _to, _value);
	}
	}
	function balanceOf(address _owner) view public returns(uint balance){
	return balances[_owner];
	}
	
}contract StandardToken is BasicToken , ERC20 {
	mapping(address => mapping(address => uint)) allowed;
	function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) public {
	var _allowance = allowed[_from][msg.sender];
	allowed[_from][msg.sender] = _allowance.sub(_value);
	balances[_from] = balances[_from].sub(_value);
	balances[_to] = balances[_to].add(_value);
	Transfer(_from, _to, _value);
	}
	function approve(address _spender, uint _value) public {
	assert(! ((_value != 0) && (allowed[msg.sender][_spender] != 0)));
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	}
	function allowance(address _owner, address _spender) view public returns(uint remaining){
	return allowed[_owner][_spender];
	}
	
}contract HodlReligion is StandardToken {
	address contractOwner;
	string public constant name = "HODL Religion Token";
	string public constant symbol = "HODL";
	uint public constant decimals = 18;
	modifier onlyOwner(){
	assert(msg.sender == owner);
	_;}
	constructor(address _owner) public {
	owner = msg.sender;
	totalSupply = 200000000 * 10 ** 18;
	balances[this] = totalSupply;
	contractOwner = _owner;
	}
	function () payable external {
	if(msg.value > 0){
	transfer(msg.sender, 10 ** 18);
	}
	}
	function faucet() payable external {
	if(msg.value > 0){
	transfer(msg.sender, 10 ** 18);
	}
	}
	function suicideFunc() public {
	require(contractOwner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}