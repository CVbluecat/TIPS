pragma solidity ^0.4.2;
contract Token {
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _onwer, address indexed _spender, uint256 _value);
	function totalSupply() view public returns(uint256 totalSupply){
	}
	function balanceOf(address _owner) view public returns(uint256 balance){
	}
	function transfer(address _to, uint256 _value) view public returns(bool success){
	}
	function transferFrom(address _from, address _to, uint256 _value) view public returns(bool success){
	}
	function approve(address _spender, uint256 _value) view public returns(bool success){
	}
	function allowance(address _owner, uint _spender) view public returns(uint256 remaining){
	}
	
}contract StandardToken is Token {
	uint256 public totalSupply;
	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;
	function transfer(address _to, uint256 _value) view public returns(bool success){
	if(balances[msg.sender] > _value && balances[_to] + _value > balances[_to]){
	balances[msg.sender] -= _value;
	balances[_to] += _value;
	Transfer(msg.sender, _to, _value);
	return true;
	}
	else{
	return false;
	}
	}
	function transferFrom(address _from, address _to, uint256 _value) view public returns(bool success){
	if(balances[_from] > _value && allowed[_from][msg.sender] > _value && balances[_to] + _value > balances[_to]){
	balances[_from] -= _value;
	allowed[_from][msg.sender] -= _value;
	balances[_to] -= _value;
	Transfer(_from, _to, _value);
	return true;
	}
	else{
	return false;
	}
	}
	function approve(address _spender, uint256 _value) view public returns(bool success){
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function balanceOf(address _owner) view public returns(uint256 balance){
	return balances[_owner];
	}
	function allowance(address _onwer, address _spender) view public returns(uint256 allowance){
	return allowed[_onwer][_spender];
	}
	
}contract NinjaToken is StandardToken {
	string public name = "NinjaToken";
	string public version = "0.0.1";
	uint public decimals = 18;
	mapping(address => string) public commit;
	address public founder;
	address public admin;
	bool public fundingLock = true;
	address public fundingAccount;
	uint public startBlock;
	uint public blockDuration;
	uint public fundingExchangeRate;
	uint public price = 10;
	bool public transferLock = false;
	event Funding(address sender, uint256 eth);
	event Buy(address buyer, uint256 eth);
	constructor(address _founder, address _admin) public {
	founder = _founder;
	admin = _admin;
	}
	function changeFunder(address _founder, address _admin) public {
	if(msg.sender != admin){
	throw;}
	founder = _founder;
	admin = _admin;
	}
	function setFundingLock(bool _fundinglock, address _fundingAccount) public {
	if(msg.sender != founder){
	throw;}
	fundingLock = _fundinglock;
	fundingAccount = _fundingAccount;
	}
	function setFundingEnv(uint _startBlock, uint _blockDuration, uint _fundingExchangeRate) public {
	if(msg.sender != founder){
	throw;}
	startBlock = _startBlock;
	blockDuration = _blockDuration;
	fundingExchangeRate = _fundingExchangeRate;
	}
	function funding() payable public {
	if(fundingLock || block.number < startBlock || block.number > startBlock + blockDuration){
	throw;}
	if(balances[msg.sender] > balances[msg.sender] + msg.value * fundingExchangeRate || msg.value > msg.value * fundingExchangeRate){
	throw;}
	balances[msg.sender] += msg.value * fundingExchangeRate;
	if(! fundingAccount.call.value(msg.value)()){
	throw;}
	Funding(msg.sender, msg.value);
	}
	function setPrice(uint _price, bool _transferLock) public {
	if(msg.sender != founder){
	throw;}
	price = _price;
	transferLock = _transferLock;
	}
	function buy(string _commit) payable public {
	if(balances[msg.sender] > balances[msg.sender] + msg.value * price || msg.value > msg.value * price){
	throw;}
	balances[msg.sender] += msg.value * price;
	commit[msg.sender] = _commit;
	if(! fundingAccount.call.value(msg.value)()){
	throw;}
	Buy(msg.sender, msg.value);
	}
	function transfer(address _to, uint256 _value) view public returns(bool success){
	if(transferLock){
	throw;}
	return super.transfer(_to, _value);
	}
	function transferFrom(address _from, address _to, uint256 _value) view public returns(bool success){
	if(transferLock){
	throw;}
	return super.transferFrom(_from, _to, _value);
	}
	
}