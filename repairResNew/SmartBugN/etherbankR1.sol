pragma solidity ^0.4.0;
contract EtherBank {
	mapping(address => uint) userBalances;
	function getBalance(address user) view public returns(uint ){
	return userBalances[user];
	}
	function addToBalance() public {
	userBalances[msg.sender] += msg.value;
	}
	function withdrawBalance() public {
	uint amountToWithdraw = userBalances[msg.sender];
	if(! (msg.sender.send(amountToWithdraw))){
	throw;}
	userBalances[msg.sender] = 0;
	}
	
}