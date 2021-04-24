pragma solidity ^0.4.0;
contract SimpleSuicide {
	address contractOwner;
	constructor(address _owner) public {
	require(contractOwner == msg.sender);
	selfdestruct(msg.sender);
	contractOwner = _owner;
	}
	
}