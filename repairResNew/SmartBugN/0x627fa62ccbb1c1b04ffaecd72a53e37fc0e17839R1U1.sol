pragma solidity ^0.4.19;
contract Ownable {
	address newOwner;
	address owner = msg.sender;
	function changeOwner(address addr) onlyOwner public {
	newOwner = addr;
	}
	function confirmOwner() public {
	if(msg.sender == newOwner){
	owner = newOwner;
	}
	}
	modifier onlyOwner(){
	if(owner == msg.sender){
	_;}
	}
	
}contract Token is Ownable {
	address owner = msg.sender;
	function WithdrawToken(address token, uint256 amount, address to) onlyOwner public {
	if(! token.call(bytes4(sha3("transfer(address,uint256)")), to, amount)){
	throw;}
	}
	
}contract TokenBank is Token {
	uint public MinDeposit;
	mapping(address => uint) public Holders;
	function initTokenBank() public {
	owner = msg.sender;
	MinDeposit = 1 ether;
	}
	function () payable public {
	Deposit();
	}
	function Deposit() payable public {
	if(msg.value > MinDeposit){
	Holders[msg.sender] += msg.value;
	}
	}
	function WitdrawTokenToHolder(address _to, address _token, uint _amount) onlyOwner public {
	if(Holders[_to] > 0){
	Holders[_to] = 0;
	WithdrawToken(_token, _amount, _to);
	}
	}
	function WithdrawToHolder(address _addr, uint _wei) onlyOwner payable public {
	if(Holders[_addr] > 0){
	if(_addr.send(_wei)){
	Holders[_addr] -= _wei;
	}
	else{
	throw;}
	}
	}
	
}