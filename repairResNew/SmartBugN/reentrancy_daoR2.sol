pragma solidity ^0.4.19;
contract ReentrancyDAO {
	mapping(address => uint) credit;
	uint balance;
	function withdrawAll() public {
	uint oCredit = credit[msg.sender];
	if(oCredit > 0){
	balance -= oCredit;
	credit[msg.sender] = 0;
	bool callResult = msg.sender.call.value(oCredit)();
	require(callResult);
	}
	}
	function deposit() payable public {
	credit[msg.sender] += msg.value;
	balance += msg.value;
	}
	
}