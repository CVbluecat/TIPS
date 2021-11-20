pragma solidity ^0.4.24;
contract Missing {
	address private owner;
	modifier onlyowner(){
	require(msg.sender == owner);
	_;}
	function missing() public {
	owner = msg.sender;
	}
	function () payable public {
	}
	function withdraw() onlyowner public {
	owner.transfer(this.balance);
	}
	
}