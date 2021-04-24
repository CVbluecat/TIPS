pragma solidity ^0.4.0;
contract SendBack {
	mapping(address => uint) userBalances;
	function withdrawBalance() public {
	uint amountToWithdraw = userBalances[msg.sender];
	userBalances[msg.sender] = 0;
	msg.sender.transfer(amountToWithdraw);
	}
	
}