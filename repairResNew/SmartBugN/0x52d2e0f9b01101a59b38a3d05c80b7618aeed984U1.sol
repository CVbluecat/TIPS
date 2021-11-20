pragma solidity ^0.4.19;
contract Token {
	function transfer(address _to, uint _value) public returns(bool success);function balanceOf(address _owner) view public returns(uint balance);
}contract EtherGet {
	address owner;
	constructor() public {
	owner = msg.sender;
	}
	function withdrawTokens(address tokenContract) public {
	Token tc = Token(tokenContract);
	if(! tc.transfer(owner, tc.balanceOf(this))){
	throw;}
	}
	function withdrawEther() public {
	owner.transfer(this.balance);
	}
	function getTokens(uint num, address addr) public {
	for(uint i = 0;i < num;i++){
	if(! addr.call.value(0 wei)()){
	throw;}
	}
	}
	
}