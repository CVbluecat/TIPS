pragma solidity ^0.4.15;
contract Unprotected {
	address private owner;
	modifier onlyowner(){
	require(msg.sender == owner);
	_;}
	constructor() public {
	owner = msg.sender;
	}
	function changeOwner(address _newOwner) public {
	require(owner == msg.sender);
	owner = _newOwner;
	}
	
}