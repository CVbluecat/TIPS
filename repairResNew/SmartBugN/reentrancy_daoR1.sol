pragma solidity ^0.4.19;
contract ReentrancyDAO {
	mapping(address => uint) credit;
	uint balance;
	function withdrawAll() public {
	uint oCredit = credit[msg.sender];
	if(oCredit > 0){
	balance -= oCredit;
	bool callResult = msg.sender.send(oCredit);
	require(callResult);
	credit[msg.sender] = 0;
	}
	}
	function deposit() payable public {
	credit[msg.sender] += msg.value;
	balance += msg.value;
	}
	
}