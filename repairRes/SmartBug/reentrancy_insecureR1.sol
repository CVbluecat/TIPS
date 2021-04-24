pragma solidity ^0.4.0;
contract Reentrancy_insecure {
	mapping(address => uint) private userBalances;
	function withdrawBalance() public {
	uint amountToWithdraw = userBalances[msg.sender];
	bool success = msg.sender.send(amountToWithdraw);
	require(success);
	userBalances[msg.sender] = 0;
	}
	
}