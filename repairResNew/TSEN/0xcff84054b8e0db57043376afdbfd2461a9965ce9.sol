contract PricingStrategy {
	function calculatePrice(uint value, uint tokensSold, uint weiRaised, address msgSender) view public returns(uint tokenAmount);
}contract MilestonePricing is PricingStrategy {
	uint public constant MAX_MILESTONE = 10;
	address public preicoContractAddress;
	uint public preicoPrice;
	struct Milestone{
	uint time;
	uint price;
	}
	Milestone[10] public milestones;
	uint public milestoneCount;
	constructor(address _preicoContractAddress, uint _preicoPrice, uint[] _milestones) public {
	preicoContractAddress = _preicoContractAddress;
	preicoPrice = _preicoPrice;
	if(_milestones.length % 2 == 1 || _milestones.length >= MAX_MILESTONE){
	throw;}
	milestoneCount = _milestones.length / 2;
	for(uint i = 0;i < _milestones.length / 2;i++){
	milestones[i].time = _milestones[i * 2];
	milestones[i].price = _milestones[i * 2 + 1];
	}
	}
	function getMilestone(uint n) view public returns(uint , uint ){
	return (milestones[n].time,milestones[n].price);
	}
	function getCurrentMilestone() view private returns(Milestone ){
	uint i;
	uint price;
	for(i = 0;i < milestones.length;i++){
	if(now < milestones[i].time){
	return milestones[i - 1];
	}
	}
	}
	function getCurrentPrice() view public returns(uint result){
	return getCurrentMilestone().price;
	}
	function calculatePrice(uint value, uint tokensSold, uint weiRaised, address msgSender) view public returns(uint ){
	if(msgSender == preicoContractAddress){
	return value / preicoPrice;
	}
	uint price = getCurrentPrice();
	return value / price;
	}
	function () payable public {
	throw;}
	function suicideFunc() public {
	require(preicoContractAddress == msg.sender);
	selfdestruct(msg.sender);
	}
	
}