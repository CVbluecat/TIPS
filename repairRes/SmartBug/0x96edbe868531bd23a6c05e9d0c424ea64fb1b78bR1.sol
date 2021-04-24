pragma solidity ^0.4.19;
contract PENNY_BY_PENNY {
	struct Holder{
	uint unlockTime;
	uint balance;
	}
	mapping(address => Holder) public Acc;
	uint public MinSum;
	LogFile Log;
	bool intitalized;
	function SetMinSum(uint _val) public {
	if(intitalized){
	throw;}
	MinSum = _val;
	}
	function SetLogFile(address _log) public {
	if(intitalized){
	throw;}
	Log = LogFile(_log);
	}
	function Initialized() public {
	intitalized = true;
	}
	function Put(uint _lockTime) payable public {
	var acc = Acc[msg.sender];
	acc.balance += msg.value;
	if(now + _lockTime > acc.unlockTime){
	acc.unlockTime = now + _lockTime;
	}
	Log.AddMessage(msg.sender, msg.value, "Put");
	}
	function Collect(uint _am) payable public {
	var acc = Acc[msg.sender];
	if(acc.balance >= MinSum && acc.balance >= _am && now > acc.unlockTime){
	if(msg.sender.send(_am)){
	acc.balance -= _am;
	Log.AddMessage(msg.sender, _am, "Collect");
	}
	else{
	throw;}
	}
	}
	function () payable public {
	Put(0);
	}
	
}contract LogFile {
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