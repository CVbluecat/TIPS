pragma solidity ^0.4.24;
contract SimpleWallet {
	address public owner = msg.sender;
	uint public depositsCount;
	modifier onlyOwner(){
	require(msg.sender == owner);
	_;}
	function () payable public {
	depositsCount++;
	}
	function withdrawAll() onlyOwner public {
	withdraw(address(this).balance);
	}
	function withdraw(uint _value) onlyOwner public {
	msg.sender.transfer(_value);
	}
	function sendMoney(address _target, uint _value) onlyOwner public {
	_target.transfer(_value);
	}
	
}