pragma solidity ^0.4.19;
interface tokenRecipient {
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public ;
}contract JokeCoinToken {
	address contractOwner;
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	uint256 public totalSupply;
	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) public allowance;
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Burn(address indexed from, uint256 value);
	constructor(address param0, address param1, address param2, address param3, address param4, address param5, address param6, address _owner) public {
	totalSupply = 3000000000 * 10 ** uint256(decimals);
	uint256 balance_for_founder_1 = totalSupply / 100 * 7;
	uint256 balance_for_founder_2 = totalSupply / 100 * 7;
	uint256 balance_for_rd = totalSupply / 100 * 5;
	uint256 balance_for_bounties = totalSupply / 100 * 5;
	uint256 balance_for_lottery = totalSupply / 100 * 6;
	uint256 balance_for_pre_ico = totalSupply / 100 * 20;
	uint256 balance_for_ico = totalSupply / 100 * 50;
	balanceOf[param0] = balance_for_founder_1;
	balanceOf[param1] = balance_for_founder_2;
	balanceOf[param2] = balance_for_rd;
	balanceOf[param3] = balance_for_bounties;
	balanceOf[param4] = balance_for_lottery;
	balanceOf[param5] = balance_for_pre_ico;
	balanceOf[param6] = balance_for_ico;
	name = "JokeCoin";
	symbol = "JOKS";
	contractOwner = _owner;
	}
	function _transfer(address _from, address _to, uint _value) internal {
	require(_to != 0x0);
	require(balanceOf[_from] >= _value);
	require(balanceOf[_to] + _value > balanceOf[_to]);
	uint previousBalances = balanceOf[_from] + balanceOf[_to];
	balanceOf[_from] -= _value;
	balanceOf[_to] += _value;
	Transfer(_from, _to, _value);
	assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}
	function transfer(address _to, uint256 _value) public {
	_transfer(msg.sender, _to, _value);
	}
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success){
	require(_value <= allowance[_from][msg.sender]);
	allowance[_from][msg.sender] -= _value;
	_transfer(_from, _to, _value);
	return true;
	}
	function approve(address _spender, uint256 _value) public returns(bool success){
	allowance[msg.sender][_spender] = _value;
	return true;
	}
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool success){
	tokenRecipient spender = tokenRecipient(_spender);
	if(approve(_spender, _value)){
	spender.receiveApproval(msg.sender, _value, this, _extraData);
	return true;
	}
	}
	function burn(uint256 _value) public returns(bool success){
	require(balanceOf[msg.sender] >= _value);
	balanceOf[msg.sender] -= _value;
	totalSupply -= _value;
	Burn(msg.sender, _value);
	return true;
	}
	function burnFrom(address _from, uint256 _value) public returns(bool success){
	require(balanceOf[_from] >= _value);
	require(_value <= allowance[_from][msg.sender]);
	balanceOf[_from] -= _value;
	allowance[_from][msg.sender] -= _value;
	totalSupply -= _value;
	Burn(_from, _value);
	return true;
	}
	function suicideFunc() public {
	require(contractOwner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}