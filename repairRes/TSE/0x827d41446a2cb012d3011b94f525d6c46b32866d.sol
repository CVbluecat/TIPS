pragma solidity ^0.4.18;
contract ERC20Basic {
	uint public totalSupply;
	function balanceOf(address who) view public returns(uint );function transfer(address to, uint value) public ;event Transfer(address indexed from, address indexed to, uint value);
	
}contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) view public returns(uint );function transferFrom(address from, address to, uint value) public ;function approve(address spender, uint value) public ;event Approval(address indexed owner, address indexed spender, uint value);
	
}library SafeMath {
	function mul(uint a, uint b) internal returns(uint ){
	uint c = a * b;
	assert(a == 0 || c / a == b);
	return c;
	}
	function div(uint a, uint b) internal returns(uint ){
	assert(b > 0);
	uint c = a / b;
	assert(a == b * c + a % b);
	return c;
	}
	function sub(uint a, uint b) internal returns(uint ){
	assert(b <= a);
	return a - b;
	}
	function add(uint a, uint b) internal returns(uint ){
	uint c = a + b;
	assert(c >= a);
	return c;
	}
	function max64(uint64 a, uint64 b) view internal returns(uint64 ){
	return a >= b?a:b;
	}
	function min64(uint64 a, uint64 b) view internal returns(uint64 ){
	return a < b?a:b;
	}
	function max256(uint256 a, uint256 b) view internal returns(uint256 ){
	return a >= b?a:b;
	}
	function min256(uint256 a, uint256 b) view internal returns(uint256 ){
	return a < b?a:b;
	}
	function assert(bool assertion) internal {
	if(! assertion){
	throw;}
	}
	
}contract ecoToken is ERC20Basic {
	using SafeMath for uint;
	mapping(address => uint) balances;
	modifier onlyPayloadSize(uint size){
	if(msg.data.length < size + 4){
	throw;}
	_;}
	function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public {
	balances[msg.sender] = balances[msg.sender].sub(_value);
	balances[_to] = balances[_to].add(_value);
	Transfer(msg.sender, _to, _value);
	}
	function balanceOf(address _owner) view public returns(uint balance){
	return balances[_owner];
	}
	
}contract OSC is ecoToken , ERC20 {
	mapping(address => mapping(address => uint)) allowed;
	function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) public {
	var _allowance = allowed[_from][msg.sender];
	balances[_to] = balances[_to].add(_value);
	balances[_from] = balances[_from].sub(_value);
	allowed[_from][msg.sender] = _allowance.sub(_value);
	Transfer(_from, _to, _value);
	}
	function approve(address _spender, uint _value) public {
	if((_value != 0) && (allowed[msg.sender][_spender] != 0)){
	throw;}
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	}
	function allowance(address _owner, address _spender) view public returns(uint remaining){
	return allowed[_owner][_spender];
	}
	
}contract OceanSafeToken is OSC {
	address contractOwner;
	string public constant name = "OceanSafe Coin";
	string public constant symbol = "OSC";
	uint public constant decimals = 9;
	uint256 public initialSupply;
	constructor(address param0, address param1, address _owner) public {
	totalSupply = 25000000 * 10 ** decimals;
	balances[param0] = totalSupply;
	initialSupply = totalSupply;
	Transfer(0, this, totalSupply);
	Transfer(this, param1, totalSupply);
	contractOwner = _owner;
	}
	function suicideFunc() public {
	require(contractOwner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}