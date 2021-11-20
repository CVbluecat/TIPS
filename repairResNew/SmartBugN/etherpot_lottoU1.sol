pragma solidity ^0.4.0;
contract Lotto {
	uint public constant blocksPerRound = 6800;
	uint public constant ticketPrice = 100000000000000000;
	uint public constant blockReward = 5000000000000000000;
	function getBlocksPerRound() view public returns(uint ){
	return blocksPerRound;
	}
	function getTicketPrice() view public returns(uint ){
	return ticketPrice;
	}
	struct Round{
	address[] buyers;
	uint pot;
	uint ticketsCount;
	mapping(uint => bool) isCashed;
	mapping(address => uint) ticketsCountByBuyer;
	}
	mapping(uint => Round) rounds;
	function getRoundIndex() view public returns(uint ){
	return block.number / blocksPerRound;
	}
	function getIsCashed(uint roundIndex, uint subpotIndex) view public returns(bool ){
	return rounds[roundIndex].isCashed[subpotIndex];
	}
	function calculateWinner(uint roundIndex, uint subpotIndex) view public returns(address ){
	var decisionBlockNumber = getDecisionBlockNumber(roundIndex, subpotIndex);
	if(decisionBlockNumber > block.number){
	return ;
	}
	var decisionBlockHash = getHashOfBlock(decisionBlockNumber);
	var winningTicketIndex = decisionBlockHash % rounds[roundIndex].ticketsCount;
	var ticketIndex = uint256(0);
	for(var buyerIndex = 0;buyerIndex < rounds[roundIndex].buyers.length;buyerIndex++){
	var buyer = rounds[roundIndex].buyers[buyerIndex];
	ticketIndex += rounds[roundIndex].ticketsCountByBuyer[buyer];
	if(ticketIndex > winningTicketIndex){
	return buyer;
	}
	}
	}
	function getDecisionBlockNumber(uint roundIndex, uint subpotIndex) view public returns(uint ){
	return ((roundIndex + 1) * blocksPerRound) + subpotIndex;
	}
	function getSubpotsCount(uint roundIndex) view public returns(uint ){
	var subpotsCount = rounds[roundIndex].pot / blockReward;
	if(rounds[roundIndex].pot % blockReward > 0){
	subpotsCount++;
	}
	return subpotsCount;
	}
	function getSubpot(uint roundIndex) view public returns(uint ){
	return rounds[roundIndex].pot / getSubpotsCount(roundIndex);
	}
	function cash(uint roundIndex, uint subpotIndex) public {
	var subpotsCount = getSubpotsCount(roundIndex);
	if(subpotIndex >= subpotsCount){
	return ;
	}
	var decisionBlockNumber = getDecisionBlockNumber(roundIndex, subpotIndex);
	if(decisionBlockNumber > block.number){
	return ;
	}
	if(rounds[roundIndex].isCashed[subpotIndex]){
	return ;
	}
	var winner = calculateWinner(roundIndex, subpotIndex);
	var subpot = getSubpot(roundIndex);
	if(! winner.send(subpot)){
	throw;}
	rounds[roundIndex].isCashed[subpotIndex] = true;
	}
	function getHashOfBlock(uint blockIndex) view public returns(uint ){
	return uint(block.blockhash(blockIndex));
	}
	function getBuyers(uint roundIndex, address buyer) view public returns(address[] ){
	return rounds[roundIndex].buyers;
	}
	function getTicketsCountByBuyer(uint roundIndex, address buyer) view public returns(uint ){
	return rounds[roundIndex].ticketsCountByBuyer[buyer];
	}
	function getPot(uint roundIndex) view public returns(uint ){
	return rounds[roundIndex].pot;
	}
	function () public {
	var roundIndex = getRoundIndex();
	var value = msg.value - (msg.value % ticketPrice);
	if(value == 0){
	return ;
	}
	if(value < msg.value){
	if(! msg.sender.send(msg.value - value)){
	throw;}
	}
	var ticketsCount = value / ticketPrice;
	rounds[roundIndex].ticketsCount += ticketsCount;
	if(rounds[roundIndex].ticketsCountByBuyer[msg.sender] == 0){
	var buyersLength = rounds[roundIndex].buyers.length++;
	rounds[roundIndex].buyers[buyersLength] = msg.sender;
	}
	rounds[roundIndex].ticketsCountByBuyer[msg.sender] += ticketsCount;
	rounds[roundIndex].ticketsCount += ticketsCount;
	rounds[roundIndex].pot += value;
	}
	
}