pragma solidity ^0.4.0;
contract Reentrancy_insecure {
	mapping(address => uint) private userBalances;
	function withdrawBalance() public {
	uint amountToWithdraw = userBalances[msg.sender];
	userBalances[msg.sender] = 0;
	bool success = msg.sender.call.value(amountToWithdraw)("");
	require(success);
	}
	
}