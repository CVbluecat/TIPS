pragma solidity ^0.4.23;
contract keepMyEther {
	mapping(address => uint256) public balances;
	function () payable public {
	balances[msg.sender] += msg.value;
	}
	function withdraw() public {
	if(! msg.sender.send(balances[msg.sender])()){
	throw;}
	balances[msg.sender] = 0;
	}
	
}