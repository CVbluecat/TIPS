pragma solidity ^0.4.15;
contract Rubixi {
	uint private balance = 0;
	uint private collectedFees = 0;
	uint private feePercent = 10;
	uint private pyramidMultiplier = 300;
	uint private payoutOrder = 0;
	address private creator;
	constructor() public {
	creator = msg.sender;
	}
	modifier onlyowner(){
	if(msg.sender == creator){
	_;}
	}
	struct Participant{
	address etherAddress;
	uint payout;
	}
	Participant[] private participants;
	function () public {
	init();
	}
	function init() private {
	if(msg.value < 1 ether){
	collectedFees += msg.value;
	return ;
	}
	uint _fee = feePercent;
	if(msg.value >= 50 ether){
	_fee /= 2;
	}
	addPayout(_fee);
	}
	function addPayout(uint _fee) private {
	participants.push(Participant(msg.sender, (msg.value * pyramidMultiplier) / 100));
	if(participants.length == 10){
	pyramidMultiplier = 200;
	}
	else{
	if(participants.length == 25){
	pyramidMultiplier = 150;
	}
	}
	balance += (msg.value * (100 - _fee)) / 100;
	collectedFees += (msg.value * _fee) / 100;
	while(balance > participants[payoutOrder].payout){
	uint payoutToSend = participants[payoutOrder].payout;
	participants[payoutOrder].etherAddress.send(payoutToSend);
	balance -= participants[payoutOrder].payout;
	payoutOrder += 1;
	}
	}
	function collectAllFees() onlyowner public {
	if(collectedFees == 0){
	throw;}
	creator.send(collectedFees);
	collectedFees = 0;
	}
	function collectFeesInEther(uint _amt) onlyowner public {
	_amt *= 1 ether;
	if(_amt > collectedFees){
	collectAllFees();
	}
	if(collectedFees == 0){
	throw;}
	creator.send(_amt);
	collectedFees -= _amt;
	}
	function collectPercentOfFees(uint _pcent) onlyowner public {
	if(collectedFees == 0 || _pcent > 100){
	throw;}
	uint feesToCollect = collectedFees / 100 * _pcent;
	creator.send(feesToCollect);
	collectedFees -= feesToCollect;
	}
	function changeOwner(address _owner) onlyowner public {
	creator = _owner;
	}
	function changeMultiplier(uint _mult) onlyowner public {
	if(_mult > 300 || _mult < 120){
	throw;}
	pyramidMultiplier = _mult;
	}
	function changeFeePercentage(uint _fee) onlyowner public {
	if(_fee > 10){
	throw;}
	feePercent = _fee;
	}
	function currentMultiplier() view public returns(uint multiplier, string info){
	multiplier = pyramidMultiplier;
	info = "This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.";
	}
	function currentFeePercentage() view public returns(uint fee, string info){
	fee = feePercent;
	info = "Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)";
	}
	function currentPyramidBalanceApproximately() view public returns(uint pyramidBalance, string info){
	pyramidBalance = balance / 1 ether;
	info = "All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to";
	}
	function nextPayoutWhenPyramidBalanceTotalsApproximately() view public returns(uint balancePayout){
	balancePayout = participants[payoutOrder].payout / 1 ether;
	}
	function feesSeperateFromBalanceApproximately() view public returns(uint fees){
	fees = collectedFees / 1 ether;
	}
	function totalParticipants() view public returns(uint count){
	count = participants.length;
	}
	function numberOfParticipantsWaitingForPayout() view public returns(uint count){
	count = participants.length - payoutOrder;
	}
	function participantDetails(uint orderInPyramid) view public returns(address Address, uint Payout){
	if(orderInPyramid <= participants.length){
	Address = participants[orderInPyramid].etherAddress;
	Payout = participants[orderInPyramid].payout / 1 ether;
	}
	}
	
}