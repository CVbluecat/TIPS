pragma solidity ^0.4.18;
contract token {
	function balanceOf(address _owner) view public returns(uint256 balance);function transfer(address _to, uint256 _value) public returns(bool success);
}contract Ownable {
	address public owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	constructor() public {
	owner = msg.sender;
	}
	modifier onlyOwner(){
	require(msg.sender == owner);
	_;}
	function transferOwnership(address newOwner) onlyOwner public {
	require(newOwner != address(0));
	OwnershipTransferred(owner, newOwner);
	owner = newOwner;
	}
	
}contract ClassyCoinAirdrop is Ownable {
	uint public numDrops;
	uint public dropAmount;
	token myToken;
	constructor(address dropper, address tokenContractAddress) public {
	myToken = token(tokenContractAddress);
	transferOwnership(dropper);
	}
	event TokenDrop(address receiver, uint amount);
	function airDrop(address[] recipients, uint amount) onlyOwner public {
	require(amount > 0);
	for(uint i = 0;i < recipients.length;i++){
	myToken.transfer(recipients[i], amount);
	TokenDrop(recipients[i], amount);
	}
	numDrops += recipients.length;
	dropAmount += recipients.length * amount;
	}
	function emergencyDrain(uint amount) onlyOwner public {
	myToken.transfer(owner, amount);
	}
	
}