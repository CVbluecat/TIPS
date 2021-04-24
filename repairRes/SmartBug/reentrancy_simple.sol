pragma solidity ^0.4.15;
contract Reentrance {
	mapping(address => uint) userBalance;
	function getBalance(address u) view public returns(uint ){
	return userBalance[u];
	}
	function addToBalance() payable public {
	userBalance[msg.sender] += msg.value;
	}
	function withdrawBalance() public {
	if(! (msg.sender.send(userBalance[msg.sender]))){
	throw;}
	userBalance[msg.sender] = 0;
	}
	
}