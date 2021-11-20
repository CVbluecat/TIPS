pragma solidity ^0.4.18;
contract Reentrance {
	mapping(address => uint) public balances;
	function donate(address _to) payable public {
	balances[_to] += msg.value;
	}
	function balanceOf(address _who) view public returns(uint balance){
	return balances[_who];
	}
	function withdraw(uint _amount) public {
	if(balances[msg.sender] >= _amount){
	if(msg.sender.send(_amount)){
	_amount;
	}
	else{
	throw;}
	balances[msg.sender] -= _amount;
	}
	}
	function () payable public {
	}
	
}