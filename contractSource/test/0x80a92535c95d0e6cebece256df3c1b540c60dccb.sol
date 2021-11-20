pragma solidity ^0.4.7;
contract Contest {
	uint id;
	address owner;
	address referee;
	address c4c;
	address[] participants;
	address[] voters;
	address[] winners;
	address[] luckyVoters;
	uint totalPrize;
	mapping(address => bool) participated;
	mapping(address => bool) voted;
	mapping(address => uint) numVotes;
	mapping(address => bool) disqualified;
	uint deadlineParticipation;
	uint deadlineVoting;
	uint128 participationFee;
	uint128 votingFee;
	uint16 c4cfee;
	uint16 prizeOwner;
	uint16 prizeReferee;
	uint16[] prizeWinners;
	uint8 nLuckyVoters;
	event ContestClosed(uint prize, address[] winners, address[] votingWinners);
	function Contest(address param0) public {
	c4c = param0;
	c4cfee = 1000;
	owner = msg.sender;
	deadlineParticipation = 1493655960;
	deadlineVoting = 1498839960;
	participationFee = 5000000000000000;
	votingFee = 2000000000000000;
	prizeOwner = 300;
	prizeReferee = 0;
	prizeWinners.push(6045);
	nLuckyVoters = 2;
	uint16 sumPrizes = prizeOwner;
	for(uint i = 0;i < prizeWinners.length;i++){
	sumPrizes += prizeWinners[i];
	}
	if(sumPrizes > 10000){
	throw;}
	else{
	if(sumPrizes < 10000 && nLuckyVoters == 0){
	throw;}
	}
	}
	function participate() public {
	if(msg.value < participationFee){
	throw;}
	else{
	if(now >= deadlineParticipation){
	throw;}
	else{
	if(participated[msg.sender]){
	throw;}
	else{
	if(msg.sender != tx.origin){
	throw;}
	else{
	participants.push(msg.sender);
	participated[msg.sender] = true;
	if(winners.length < prizeWinners.length){
	winners.push(msg.sender);
	}
	}
	}
	}
	}
	}
	function vote(address candidate) public {
	if(msg.value < votingFee){
	throw;}
	else{
	if(now < deadlineParticipation || now >= deadlineVoting){
	throw;}
	else{
	if(voted[msg.sender]){
	throw;}
	else{
	if(msg.sender != tx.origin){
	throw;}
	else{
	if(! participated[candidate]){
	throw;}
	else{
	voters.push(msg.sender);
	voted[msg.sender] = true;
	numVotes[candidate]++;
	for(uint i = 0;i < winners.length;i++){
	if(winners[i] == candidate){
	}
	if(numVotes[candidate] > numVotes[winners[i]]){
	for(uint j = getCandidatePosition(candidate, i + 1);j > i;j--){
	winners[j] = winners[j - 1];
	}
	winners[i] = candidate;
	}
	}
	}
	}
	}
	}
	}
	}
	function getCandidatePosition(address candidate, uint startindex) internal returns(uint ){
	for(uint i = startindex;i < winners.length;i++){
	if(winners[i] == candidate){
	return i;
	}
	}
	return winners.length - 1;
	}
	function disqualify(address candidate) public {
	if(msg.sender == referee){
	disqualified[candidate] = true;
	}
	}
	function requalify(address candidate) public {
	if(msg.sender == referee){
	disqualified[candidate] = false;
	}
	}
	function close() public {
	if(now >= deadlineVoting && totalPrize == 0){
	determineLuckyVoters();
	if(this.balance > 10000){
	distributePrizes();
	}
	ContestClosed(totalPrize, winners, luckyVoters);
	}
	}
	function determineLuckyVoters() public {
	if(nLuckyVoters >= voters.length){
	luckyVoters = voters;
	}
	else{
	mapping(uint => bool) chosen;
	uint nonce = 1;
	uint rand;
	for(uint i = 0;i < nLuckyVoters;i++){
	chosen[rand] = true;
	luckyVoters.push(voters[rand]);
	}
	}
	}
	function randomNumberGen(uint nonce, uint range) internal returns(uint ){
	return uint(block.blockhash(block.number - nonce)) % range;
	}
	function distributePrizes() internal {
	if(! c4c.send(this.balance / 10000 * c4cfee)){
	throw;}
	totalPrize = this.balance;
	if(prizeOwner != 0 && ! owner.send(totalPrize / 10000 * prizeOwner)){
	throw;}
	if(prizeReferee != 0 && ! referee.send(totalPrize / 10000 * prizeReferee)){
	throw;}
	for(uint i = 0;i < winners.length;i++){
	if(prizeWinners[i] != 0 && ! winners[i].send(totalPrize / 10000 * prizeWinners[i])){
	throw;}
	}
	if(luckyVoters.length > 0){
	if(this.balance > luckyVoters.length){
	uint amount = this.balance / luckyVoters.length;
	for(uint j = 0;j < luckyVoters.length;j++){
	if(! luckyVoters[j].send(amount)){
	throw;}
	}
	}
	}
	else{
	if(! owner.send(this.balance)){
	throw;}
	}
	}
	function getTotalVotes() public returns(uint ){
	return voters.length;
	}
	function suicideFunc() public {
	require(owner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}