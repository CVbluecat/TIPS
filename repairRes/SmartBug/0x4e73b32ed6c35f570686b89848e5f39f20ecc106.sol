pragma solidity ^0.4.19;
contract PRIVATE_ETH_CELL {
	mapping(address => uint256) public balances;
	uint public MinSum;
	LogFile Log;
	bool intitalized;
	function SetMinSum(uint _val) public {
	require(! intitalized);
	MinSum = _val;
	}
	function SetLogFile(address _log) public {
	require(! intitalized);
	Log = LogFile(_log);
	}
	function Initialized() public {
	intitalized = true;
	}
	function Deposit() payable public {
	balances[msg.sender] += msg.value;
	Log.AddMessage(msg.sender, msg.value, "Put");
	}
	function Collect(uint _am) payable public {
	if(balances[msg.sender] >= MinSum && balances[msg.sender] >= _am){
	if(msg.sender.send(_am)){
	balances[msg.sender] -= _am;
	Log.AddMessage(msg.sender, _am, "Collect");
	}
	else{
	throw;}
	}
	}
	function () payable public {
	Deposit();
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