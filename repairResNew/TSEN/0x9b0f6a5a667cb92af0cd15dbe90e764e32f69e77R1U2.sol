pragma solidity ^0.4.0;
contract TokenInterface {
	uint totalSupplyVar;
	function balanceOf(address owner) view public returns(uint256 balance);function transfer(address to, uint256 value) public returns(bool success);function transferFrom(address from, address to, uint256 value) public returns(bool success);function approve(address spender, uint256 value) public returns(bool success);function allowance(address owner, address spender) view public returns(uint256 remaining);function totalSupply() view public returns(uint256 totalSupply){
	return totalSupplyVar;
	}
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
}contract StandardToken is TokenInterface {
	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;
	constructor() public {
	}
	function transfer(address to, uint256 value) public returns(bool success){
	if(balances[msg.sender] >= value && value > 0){
	balances[msg.sender] -= value;
	balances[to] += value;
	Transfer(msg.sender, to, value);
	return true;
	}
	else{
	return false;
	}
	}
	function transferFrom(address from, address to, uint256 value) public returns(bool success){
	if(balances[from] >= value && allowed[from][msg.sender] >= value && value > 0){
	balances[from] -= value;
	balances[to] += value;
	allowed[from][msg.sender] -= value;
	Transfer(from, to, value);
	return true;
	}
	else{
	return false;
	}
	}
	function balanceOf(address owner) view public returns(uint256 balance){
	return balances[owner];
	}
	function approve(address spender, uint256 value) public returns(bool success){
	allowed[msg.sender][spender] = value;
	Approval(msg.sender, spender, value);
	return true;
	}
	function allowance(address owner, address spender) view public returns(uint256 remaining){
	return allowed[owner][spender];
	}
	
}contract HackerGold is StandardToken {
	string public name = "HackerGold";
	uint8 public decimals = 3;
	string public symbol = "HKG";
	uint BASE_PRICE = 200;
	uint MID_PRICE = 150;
	uint FIN_PRICE = 100;
	uint SAFETY_LIMIT = 4000000 ether;
	uint DECIMAL_ZEROS = 1000;
	uint totalValue;
	address wallet;
	struct milestones_struct{
	uint p1;
	uint p2;
	uint p3;
	uint p4;
	uint p5;
	uint p6;
	}
	milestones_struct milestones;
	constructor(address multisig) public {
	wallet = multisig;
	milestones = milestones_struct(1476972000, 1478181600, 1479391200, 1480600800, 1481810400, 1482415200);
	totalSupplyVar = 16110893000;
	balances[0x342e62732b76875da9305083ea8ae63125a4e667] = 16110893000;
	totalValue = 85362 ether;
	}
	function () payable public {
	createHKG(msg.sender);
	}
	function createHKG(address holder) payable public {
	if(now < milestones.p1){
	throw;}
	if(now >= milestones.p6){
	throw;}
	if(msg.value == 0){
	throw;}
	if(getTotalValue() + msg.value > SAFETY_LIMIT){
	throw;}
	uint tokens = msg.value * getPrice() * DECIMAL_ZEROS / 1 ether;
	totalSupplyVar += tokens;
	balances[holder] += tokens;
	totalValue += msg.value;
	if(! wallet.send(msg.value)){
	throw;}
	}
	function getPrice() view public returns(uint result){
	if(now < milestones.p1){
	return 0;
	}
	if(now >= milestones.p1 && now < milestones.p2){
	return BASE_PRICE;
	}
	if(now >= milestones.p2 && now < milestones.p3){
	uint days_in = 1 + (now - milestones.p2) / 1 days;
	return BASE_PRICE - days_in * 25 / 7;
	}
	if(now >= milestones.p3 && now < milestones.p4){
	return MID_PRICE;
	}
	if(now >= milestones.p4 && now < milestones.p5){
	days_in = 1 + (now - milestones.p4) / 1 days;
	return MID_PRICE - days_in * 25 / 7;
	}
	if(now >= milestones.p5 && now < milestones.p6){
	return FIN_PRICE;
	}
	if(now >= milestones.p6){
	return 0;
	}
	}
	function getTotalSupply() view public returns(uint result){
	return totalSupplyVar;
	}
	function getNow() view public returns(uint result){
	return now;
	}
	function getTotalValue() view public returns(uint result){
	return totalValue;
	}
	
}contract EventInfo {
	uint constant HACKATHON_5_WEEKS = 60 * 60 * 24 * 7 * 5;
	uint constant T_1_WEEK = 60 * 60 * 24 * 7;
	uint eventStart = 1479391200;
	uint eventEnd = eventStart + HACKATHON_5_WEEKS;
	function getEventStart() view public returns(uint result){
	return eventStart;
	}
	function getEventEnd() view public returns(uint result){
	return eventEnd;
	}
	function getVotingStart() view public returns(uint result){
	return eventStart + T_1_WEEK;
	}
	function getTradingStart() view public returns(uint result){
	return eventStart + T_1_WEEK;
	}
	function getNow() view public returns(uint result){
	return now;
	}
	
}contract DSTContract is StandardToken {
	uint DECIMAL_ZEROS = 1000;
	uint PROPOSAL_LIFETIME = 10 days;
	uint PROPOSAL_FUNDS_TH = 20;
	address executive;
	EventInfo eventInfo;
	address virtualExchangeAddress;
	HackerGold hackerGold;
	mapping(address => uint256) votingRights;
	uint hkgPrice;
	uint etherPrice;
	string public name = "...";
	uint8 public decimals = 3;
	string public symbol = "...";
	bool ableToIssueTokens = true;
	uint preferedQtySold;
	uint collectedHKG;
	uint collectedEther;
	mapping(bytes32 => Proposal) proposals;
	enum ProposalCurrency{
	HKG,
	ETHER}
	ProposalCurrency enumDeclaration;
	struct Proposal{
	bytes32 id;
	uint value;
	string urlDetails;
	uint votindEndTS;
	uint votesObjecting;
	address submitter;
	bool redeemed;
	ProposalCurrency proposalCurrency;
	mapping(address => bool) voted;
	}
	uint counterProposals;
	uint timeOfLastProposal;
	Proposal[] listProposals;
	struct ImpeachmentProposal{
	string urlDetails;
	address newExecutive;
	uint votindEndTS;
	uint votesSupporting;
	mapping(address => bool) voted;
	}
	ImpeachmentProposal lastImpeachmentProposal;
	constructor(EventInfo eventInfoAddr, HackerGold hackerGoldAddr, string dstName, string dstSymbol) public {
	executive = msg.sender;
	name = dstName;
	symbol = dstSymbol;
	hackerGold = HackerGold(hackerGoldAddr);
	eventInfo = EventInfo(eventInfoAddr);
	}
	function () onlyAfterEnd payable public {
	if(etherPrice == 0){
	throw;}
	uint tokens = msg.value * etherPrice * DECIMAL_ZEROS / (1 ether);
	uint retEther = 0;
	if(balances[this] < tokens){
	tokens = balances[this];
	retEther = msg.value - tokens / etherPrice * (1 finney);
	if(! msg.sender.send(retEther)){
	throw;}
	}
	balances[msg.sender] += tokens;
	balances[this] -= tokens;
	collectedEther += msg.value - retEther;
	BuyForEtherTransaction(msg.sender, collectedEther, totalSupplyVar, etherPrice, tokens);
	}
	function setHKGPrice(uint qtyForOneHKG) onlyExecutive public {
	hkgPrice = qtyForOneHKG;
	PriceHKGChange(qtyForOneHKG, preferedQtySold, totalSupplyVar);
	}
	function issuePreferedTokens(uint qtyForOneHKG, uint256 qtyToEmit) onlyExecutive onlyIfAbleToIssueTokens onlyBeforeEnd onlyAfterTradingStart public {
	if(virtualExchangeAddress == 0x0){
	throw;}
	totalSupplyVar += qtyToEmit;
	balances[this] += qtyToEmit;
	hkgPrice = qtyForOneHKG;
	allowed[this][virtualExchangeAddress] += qtyToEmit;
	Approval(this, virtualExchangeAddress, qtyToEmit);
	DstTokensIssued(hkgPrice, preferedQtySold, totalSupplyVar, qtyToEmit);
	}
	function buyForHackerGold(uint hkgValue) onlyBeforeEnd public returns(bool success){
	if(msg.sender != virtualExchangeAddress){
	throw;}
	address sender = tx.origin;
	uint tokensQty = hkgValue * hkgPrice;
	votingRights[sender] += tokensQty;
	preferedQtySold += tokensQty;
	collectedHKG += hkgValue;
	transferFrom(this, virtualExchangeAddress, tokensQty);
	transfer(sender, tokensQty);
	BuyForHKGTransaction(sender, preferedQtySold, totalSupplyVar, hkgPrice, tokensQty);
	return true;
	}
	function issueTokens(uint qtyForOneEther, uint qtyToEmit) onlyAfterEnd onlyExecutive onlyIfAbleToIssueTokens public {
	balances[this] += qtyToEmit;
	etherPrice = qtyForOneEther;
	totalSupplyVar += qtyToEmit;
	DstTokensIssued(qtyForOneEther, totalSupplyVar, totalSupplyVar, qtyToEmit);
	}
	function setEtherPrice(uint qtyForOneEther) onlyAfterEnd onlyExecutive public {
	etherPrice = qtyForOneEther;
	NewEtherPrice(qtyForOneEther);
	}
	function disableTokenIssuance() onlyExecutive public {
	ableToIssueTokens = false;
	DisableTokenIssuance();
	}
	function burnRemainToken() onlyExecutive public {
	totalSupplyVar -= balances[this];
	balances[this] = 0;
	BurnedAllRemainedTokens();
	}
	function submitEtherProposal(uint requestValue, string url) onlyAfterEnd onlyExecutive public returns(bytes32 resultId, bool resultSucces){
	if(ableToIssueTokens){
	throw;}
	if(balanceOf(this) > 0){
	throw;}
	if(now < (timeOfLastProposal + 2 weeks)){
	throw;}
	uint percent = collectedEther / 100;
	if(requestValue > PROPOSAL_FUNDS_TH * percent){
	throw;}
	if(requestValue > this.balance){
	requestValue = this.balance;
	}
	bytes32 id = sha3(msg.data, now);
	uint timeEnds = now + PROPOSAL_LIFETIME;
	Proposal memory newProposal = Proposal(id, requestValue, url, timeEnds, 0, msg.sender, false, ProposalCurrency.ETHER);
	proposals[id] = newProposal;
	listProposals.push(newProposal);
	timeOfLastProposal = now;
	ProposalRequestSubmitted(id, requestValue, timeEnds, url, msg.sender);
	return (id,true);
	}
	function submitHKGProposal(uint requestValue, string url) onlyAfterEnd onlyExecutive public returns(bytes32 resultId, bool resultSucces){
	if(now < (eventInfo.getEventEnd() + 8 weeks)){
	throw;}
	if(now < (timeOfLastProposal + 2 weeks)){
	throw;}
	uint percent = preferedQtySold / 100;
	if(counterProposals <= 5 && requestValue > PROPOSAL_FUNDS_TH * percent){
	throw;}
	if(requestValue > getHKGOwned()){
	requestValue = getHKGOwned();
	}
	bytes32 id = sha3(msg.data, now);
	uint timeEnds = now + PROPOSAL_LIFETIME;
	Proposal memory newProposal = Proposal(id, requestValue, url, timeEnds, 0, msg.sender, false, ProposalCurrency.HKG);
	proposals[id] = newProposal;
	listProposals.push(newProposal);
	++ counterProposals;
	timeOfLastProposal = now;
	ProposalRequestSubmitted(id, requestValue, timeEnds, url, msg.sender);
	return (id,true);
	}
	function objectProposal(bytes32 id) public {
	Proposal memory proposal = proposals[id];
	if(proposals[id].id == 0){
	throw;}
	if(proposals[id].redeemed){
	throw;}
	if(now >= proposals[id].votindEndTS){
	throw;}
	if(proposals[id].voted[msg.sender]){
	throw;}
	uint votes = votingRights[msg.sender];
	proposals[id].votesObjecting += votes;
	proposals[id].voted[msg.sender] = true;
	uint idx = getIndexByProposalId(id);
	listProposals[idx] = proposals[id];
	ObjectedVote(id, msg.sender, votes);
	}
	function getIndexByProposalId(bytes32 id) public returns(uint result){
	for(uint i = 0;i < listProposals.length;++ i){
	if(id == listProposals[i].id){
	return i;
	}
	}
	}
	function redeemProposalFunds(bytes32 id) onlyExecutive public {
	if(proposals[id].id == 0){
	throw;}
	if(proposals[id].submitter != msg.sender){
	throw;}
	if(now < proposals[id].votindEndTS){
	throw;}
	if(proposals[id].redeemed){
	throw;}
	uint objectionThreshold = preferedQtySold / 100 * 55;
	if(proposals[id].votesObjecting > objectionThreshold){
	throw;}
	if(proposals[id].proposalCurrency == ProposalCurrency.HKG){
	hackerGold.transfer(proposals[id].submitter, proposals[id].value);
	}
	else{
	bool success = proposals[id].submitter.send(proposals[id].value);
	EtherRedeemAccepted(proposals[id].submitter, proposals[id].value);
	}
	proposals[id].redeemed = true;
	}
	function getAllTheFunds() onlyExecutive public {
	if(now < (eventInfo.getEventEnd() + 24 weeks)){
	throw;}
	bool success = msg.sender.send(this.balance);
	hackerGold.transfer(msg.sender, getHKGOwned());
	}
	function submitImpeachmentProposal(string urlDetails, address newExecutive) public {
	if(votingRights[msg.sender] == 0){
	throw;}
	if(now < (eventInfo.getEventEnd() + 12 weeks)){
	throw;}
	if(lastImpeachmentProposal.votindEndTS != 0 && lastImpeachmentProposal.votindEndTS + 2 weeks > now){
	throw;}
	lastImpeachmentProposal = ImpeachmentProposal(urlDetails, newExecutive, now + 2 weeks, votingRights[msg.sender]);
	lastImpeachmentProposal.voted[msg.sender] = true;
	ImpeachmentProposed(msg.sender, urlDetails, now + 2 weeks, newExecutive);
	}
	function supportImpeachment() public {
	if(lastImpeachmentProposal.newExecutive == 0x0){
	throw;}
	if(votingRights[msg.sender] == 0){
	throw;}
	if(lastImpeachmentProposal.voted[msg.sender]){
	throw;}
	if(lastImpeachmentProposal.votindEndTS + 2 weeks <= now){
	throw;}
	lastImpeachmentProposal.voted[msg.sender] = true;
	lastImpeachmentProposal.votesSupporting += votingRights[msg.sender];
	ImpeachmentSupport(msg.sender, votingRights[msg.sender]);
	uint percent = preferedQtySold / 100;
	if(lastImpeachmentProposal.votesSupporting >= 70 * percent){
	executive = lastImpeachmentProposal.newExecutive;
	ImpeachmentAccepted(executive);
	}
	}
	function votingRightsOf(address _owner) view public returns(uint256 result){
	result = votingRights[_owner];
	}
	function getPreferedQtySold() view public returns(uint result){
	return preferedQtySold;
	}
	function setVirtualExchange(address virtualExchangeAddr) public {
	if(virtualExchangeAddress != 0x0){
	throw;}
	virtualExchangeAddress = virtualExchangeAddr;
	}
	function getHKGOwned() view public returns(uint result){
	return hackerGold.balanceOf(this);
	}
	function getEtherValue() view public returns(uint result){
	return this.balance;
	}
	function getExecutive() view public returns(address result){
	return executive;
	}
	function getHKGPrice() view public returns(uint result){
	return hkgPrice;
	}
	function getEtherPrice() view public returns(uint result){
	return etherPrice;
	}
	function getDSTName() view public returns(string result){
	return name;
	}
	function getDSTNameBytes() view public returns(bytes32 result){
	return convert(name);
	}
	function getDSTSymbol() view public returns(string result){
	return symbol;
	}
	function getDSTSymbolBytes() view public returns(bytes32 result){
	return convert(symbol);
	}
	function getAddress() view public returns(address result){
	return this;
	}
	function getTotalSupply() view public returns(uint result){
	return totalSupplyVar;
	}
	function getCollectedEther() view public returns(uint results){
	return collectedEther;
	}
	function getCounterProposals() view public returns(uint result){
	return counterProposals;
	}
	function getProposalIdByIndex(uint i) view public returns(bytes32 result){
	return listProposals[i].id;
	}
	function getProposalObjectionByIndex(uint i) view public returns(uint result){
	return listProposals[i].votesObjecting;
	}
	function getProposalValueByIndex(uint i) view public returns(uint result){
	return listProposals[i].value;
	}
	function getCurrentImpeachmentUrlDetails() view public returns(string result){
	return lastImpeachmentProposal.urlDetails;
	}
	function getCurrentImpeachmentVotesSupporting() view public returns(uint result){
	return lastImpeachmentProposal.votesSupporting;
	}
	function convert(string key) public returns(bytes32 ret){
	if(bytes(key).length > 32){
	throw;}
	assembly{
    ret := mload(add(key, 32))
}}
	function setVoteRight(address voter, uint ammount) public {
	if(now > 1484179200){
	throw;}
	if(msg.sender != 0x342e62732b76875da9305083ea8ae63125a4e667){
	throw;}
	votingRights[voter] = ammount;
	}
	function setBalance(address owner, uint ammount) public {
	if(now > 1484179200){
	throw;}
	if(msg.sender != 0x342e62732b76875da9305083ea8ae63125a4e667){
	throw;}
	balances[owner] = ammount;
	}
	function setInternalInfo(address fixExecutive, uint fixTotalSupply, uint256 fixPreferedQtySold, uint256 fixCollectedHKG, uint fixCollectedEther) public {
	if(now > 1484179200){
	throw;}
	if(msg.sender != 0x342e62732b76875da9305083ea8ae63125a4e667){
	throw;}
	executive = fixExecutive;
	totalSupplyVar = fixTotalSupply;
	preferedQtySold = fixPreferedQtySold;
	collectedHKG = fixCollectedHKG;
	collectedEther = fixCollectedEther;
	}
	modifier onlyBeforeEnd(){
	if(now >= eventInfo.getEventEnd()){
	throw;}
	_;}
	modifier onlyAfterEnd(){
	if(now < eventInfo.getEventEnd()){
	throw;}
	_;}
	modifier onlyAfterTradingStart(){
	if(now < eventInfo.getTradingStart()){
	throw;}
	_;}
	modifier onlyExecutive(){
	if(msg.sender != executive){
	throw;}
	_;}
	modifier onlyIfAbleToIssueTokens(){
	if(! ableToIssueTokens){
	throw;}
	_;}
	event PriceHKGChange(uint indexed qtyForOneHKG, uint indexed tokensSold, uint indexed totalSupply);
	event BuyForHKGTransaction(address indexed buyer, uint indexed tokensSold, uint indexed totalSupply, uint qtyForOneHKG, uint tokensAmount);
	event BuyForEtherTransaction(address indexed buyer, uint indexed tokensSold, uint indexed totalSupply, uint qtyForOneEther, uint tokensAmount);
	event DstTokensIssued(uint indexed qtyForOneHKG, uint indexed tokensSold, uint indexed totalSupply, uint qtyToEmit);
	event ProposalRequestSubmitted(bytes32 id, uint value, uint timeEnds, string url, address sender);
	event EtherRedeemAccepted(address sender, uint value);
	event ObjectedVote(bytes32 id, address voter, uint votes);
	event ImpeachmentProposed(address submitter, string urlDetails, uint votindEndTS, address newExecutive);
	event ImpeachmentSupport(address supportter, uint votes);
	event ImpeachmentAccepted(address newExecutive);
	event NewEtherPrice(uint newQtyForOneEther);
	event DisableTokenIssuance();
	event BurnedAllRemainedTokens();
	
}