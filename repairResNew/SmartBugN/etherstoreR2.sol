pragma solidity ^0.4.0;
contract EtherStore {
	uint256 public withdrawalLimit = 1 ether;
	mapping(address => uint256) public lastWithdrawTime;
	mapping(address => uint256) public balances;
	function depositFunds() payable public {
	balances[msg.sender] += msg.value;
	}
	function withdrawFunds(uint256 _weiToWithdraw) public {
	require(balances[msg.sender] >= _weiToWithdraw);
	require(_weiToWithdraw <= withdrawalLimit);
	require(now >= lastWithdrawTime[msg.sender] + 1 weeks);
	balances[msg.sender] -= _weiToWithdraw;
	lastWithdrawTime[msg.sender] = now;
	require(msg.sender.call.value(_weiToWithdraw)());
	}
	
}