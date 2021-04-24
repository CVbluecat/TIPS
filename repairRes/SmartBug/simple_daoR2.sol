pragma solidity ^0.4.2;
contract SimpleDAO {
	mapping(address => uint) public credit;
	function donate(address to) payable public {
	credit[to] += msg.value;
	}
	function withdraw(uint amount) public {
	if(credit[msg.sender] >= amount){
	credit[msg.sender] -= amount;
	bool res = msg.sender.call.value(amount)();
	}
	}
	function queryCredit(address to) public returns(uint ){
	return credit[to];
	}
	
}