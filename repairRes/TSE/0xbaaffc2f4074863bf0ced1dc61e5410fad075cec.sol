pragma solidity ^0.4.19;
contract sendlimiter {
	function () payable public {
	require(this.balance + msg.value < 100000000);
	}
	
}