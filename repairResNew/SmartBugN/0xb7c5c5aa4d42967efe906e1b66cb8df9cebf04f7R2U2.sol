pragma solidity ^0.4.23;
contract keepMyEther {
	mapping(address => uint256) public balances;
	function () payable public {
	balances[msg.sender] += msg.value;
	}
	function withdraw() public {
	balances[msg.sender] = 0;
	msg.sender.transfer(balances[msg.sender]);
	}
	
}