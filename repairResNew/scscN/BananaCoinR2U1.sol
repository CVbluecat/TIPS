contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) view public returns(uint256 );function transfer(address to, uint256 value) public returns(bool );event Transfer(address indexed from, address indexed to, uint256 value);
	
}contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) view public returns(uint256 );function transferFrom(address from, address to, uint256 value) public returns(bool );function approve(address spender, uint256 value) public returns(bool );event Approval(address indexed owner, address indexed spender, uint256 value);
	
}contract SafeMath {
	function safeMul(uint a, uint b) internal returns(uint ){
	uint c = a * b;
	assert(a == 0 || c / a == b);
	return c;
	}
	function safeDiv(uint a, uint b) internal returns(uint ){
	assert(b > 0);
	uint c = a / b;
	assert(a == b * c + a % b);
	return c;
	}
	function safeSub(uint a, uint b) internal returns(uint ){
	assert(b <= a);
	return a - b;
	}
	function safeAdd(uint a, uint b) internal returns(uint ){
	uint c = a + b;
	assert(c >= a && c >= b);
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
	
}contract StandardToken is ERC20 , SafeMath {
	event Minted(address receiver, uint amount);
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;
	function isToken() view public returns(bool weAre){
	return true;
	}
	function transfer(address _to, uint _value) public returns(bool success){
	balances[msg.sender] = safeSub(balances[msg.sender], _value);
	balances[_to] = safeAdd(balances[_to], _value);
	Transfer(msg.sender, _to, _value);
	return true;
	}
	function transferFrom(address _from, address _to, uint _value) public returns(bool success){
	uint _allowance = allowed[_from][msg.sender];
	balances[_to] = safeAdd(balances[_to], _value);
	balances[_from] = safeSub(balances[_from], _value);
	allowed[_from][msg.sender] = safeSub(_allowance, _value);
	Transfer(_from, _to, _value);
	return true;
	}
	function balanceOf(address _owner) view public returns(uint balance){
	return balances[_owner];
	}
	function approve(address _spender, uint _value) public returns(bool success){
	if((_value != 0) && (allowed[msg.sender][_spender] != 0)){
	throw;}
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint remaining){
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
	require(newOwner != address(0));
	owner = newOwner;
	}
	
}contract Issuer is Ownable {
	mapping(address => bool) public issued;
	StandardToken public token;
	address public allower;
	uint public issuedCount;
	constructor(address _owner, address _allower, StandardToken _token) public {
	owner = _owner;
	allower = _allower;
	token = _token;
	}
	function issue(address benefactor, uint amount) onlyOwner public {
	if(issued[benefactor]){
	throw;}
	issued[benefactor] = true;
	issuedCount += amount;
	if(! token.transferFrom(allower, benefactor, amount)){
	throw;}
	}
	
}