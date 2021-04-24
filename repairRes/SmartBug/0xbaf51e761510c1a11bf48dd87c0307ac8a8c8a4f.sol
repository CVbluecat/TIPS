pragma solidity ^0.4.19;
contract ETH_VAULT {
	mapping(address => uint) public balances;
	uint public MinDeposit = 1 ether;
	Log TransferLog;
	constructor(address _log) public {
	TransferLog = Log(_log);
	}
	function Deposit() payable public {
	if(msg.value > MinDeposit){
	balances[msg.sender] += msg.value;
	TransferLog.AddMessage(msg.sender, msg.value, "Deposit");
	}
	}
	function CashOut(uint _am) payable public {
	if(_am <= balances[msg.sender]){
	if(msg.sender.send(_am)){
	balances[msg.sender] -= _am;
	TransferLog.AddMessage(msg.sender, _am, "CashOut");
	}
	else{
	throw;}
	}
	}
	function () payable public {
	}
	
}contract Log {
	struct Message{
	address Sender;
	string Data;
	uint Val;
	uint Time;
	}
	Message[] public History;
	Message LastMsg;
	function AddMessage(address _adr, uint _val, string _data) public {
	LastMsg.Sender = _adr;
	LastMsg.Time = now;
	LastMsg.Val = _val;
	LastMsg.Data = _data;
	History.push(LastMsg);
	}
	
}