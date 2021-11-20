pragma solidity ^0.4.8;
contract SafeMath {
	function safeMul(uint a, uint b) internal returns(uint ){
	uint c = a * b;
	assert(a == 0 || c / a == b);
	return c;
	}
	function safeDiv(uint a, uint b) internal returns(uint ){
	assert(b > 0);
	uint c = a / b;
	assert(a == b * c + a % b);
	return c;
	}
	function safeSub(uint a, uint b) internal returns(uint ){
	assert(b <= a);
	return a - b;
	}
	function safeAdd(uint a, uint b) internal returns(uint ){
	uint c = a + b;
	assert(c >= a && c >= b);
	return c;
	}
	function max64(uint64 a, uint64 b) view internal returns(uint64 ){
	return a >= b?a:b;
	}
	function min64(uint64 a, uint64 b) view internal returns(uint64 ){
	return a < b?a:b;
	}
	function max256(uint256 a, uint256 b) view internal returns(uint256 ){
	return a >= b?a:b;
	}
	function min256(uint256 a, uint256 b) view internal returns(uint256 ){
	return a < b?a:b;
	}
	
}contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) view public returns(uint256 );function transfer(address to, uint256 value) public returns(bool );event Transfer(address indexed from, address indexed to, uint256 value);
	
}contract Ownable {
	address public owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	constructor() public {
	owner = msg.sender;
	}
	modifier onlyOwner(){
	require(msg.sender == owner);
	_;}
	function transferOwnership(address newOwner) onlyOwner public {
	require(newOwner != address(0));
	OwnershipTransferred(owner, newOwner);
	owner = newOwner;
	}
	
}library SafeMathLibExt {
	function times(uint a, uint b) public returns(uint ){
	uint c = a * b;
	assert(a == 0 || c / a == b);
	return c;
	}
	function divides(uint a, uint b) public returns(uint ){
	assert(b > 0);
	uint c = a / b;
	assert(a == b * c + a % b);
	return c;
	}
	function minus(uint a, uint b) public returns(uint ){
	assert(b <= a);
	return a - b;
	}
	function plus(uint a, uint b) public returns(uint ){
	uint c = a + b;
	assert(c >= a);
	return c;
	}
	
}contract Haltable is Ownable {
	bool public halted;
	modifier stopInEmergency(){
	if(halted){
	throw;}
	_;}
	modifier stopNonOwnersInEmergency(){
	if(halted && msg.sender != owner){
	throw;}
	_;}
	modifier onlyInEmergency(){
	if(! halted){
	throw;}
	_;}
	function halt() onlyOwner external {
	halted = true;
	}
	function unhalt() onlyOwner onlyInEmergency external {
	halted = false;
	}
	
}contract PricingStrategy {
	function isPricingStrategy() view public returns(bool ){
	return true;
	}
	function isSane(address crowdsale) view public returns(bool ){
	return true;
	}
	function isPresalePurchase(address purchaser) view public returns(bool ){
	return false;
	}
	function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) view public returns(uint tokenAmount);
}contract FinalizeAgent {
	function isFinalizeAgent() view public returns(bool ){
	return true;
	}
	function isSane() view public returns(bool );function finalizeCrowdsale() public ;
}contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) view public returns(uint256 );function transferFrom(address from, address to, uint256 value) public returns(bool );function approve(address spender, uint256 value) public returns(bool );event Approval(address indexed owner, address indexed spender, uint256 value);
	
}contract FractionalERC20Ext is ERC20 {
	uint public decimals;
	uint public minCap;
	
}contract CrowdsaleExt is Haltable {
	uint public MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE = 5;
	using SafeMathLibExt for uint;
	FractionalERC20Ext public token;
	PricingStrategy public pricingStrategy;
	FinalizeAgent public finalizeAgent;
	address public multisigWallet;
	uint public minimumFundingGoal;
	uint public startsAt;
	uint public endsAt;
	uint public tokensSold = 0;
	uint public weiRaised = 0;
	uint public presaleWeiRaised = 0;
	uint public investorCount = 0;
	uint public loadedRefund = 0;
	uint public weiRefunded = 0;
	bool public finalized;
	bool public requireCustomerId;
	bool public isWhiteListed;
	address[] public joinedCrowdsales;
	uint public joinedCrowdsalesLen = 0;
	address public lastCrowdsale;
	bool public requiredSignedAddress;
	address public signerAddress;
	mapping(address => uint256) public investedAmountOf;
	mapping(address => uint256) public tokenAmountOf;
	struct WhiteListData{
	bool status;
	uint minCap;
	uint maxCap;
	}
	bool public isUpdatable;
	mapping(address => WhiteListData) public earlyParticipantWhitelist;
	uint public ownerTestValue;
	enum State{
	Unknown,
	Preparing,
	PreFunding,
	Funding,
	Success,
	Failure,
	Finalized,
	Refunding}
	event Invested(address investor, uint weiAmount, uint tokenAmount, uint128 customerId);
	event Refund(address investor, uint weiAmount);
	event InvestmentPolicyChanged(bool newRequireCustomerId, bool newRequiredSignedAddress, address newSignerAddress);
	event Whitelisted(address addr, bool status);
	event StartsAtChanged(uint newStartsAt);
	event EndsAtChanged(uint newEndsAt);
	constructor(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, bool _isUpdatable, bool _isWhiteListed) public {
	owner = msg.sender;
	token = FractionalERC20Ext(_token);
	setPricingStrategy(_pricingStrategy);
	multisigWallet = _multisigWallet;
	if(multisigWallet == 0){
	throw;}
	if(_start == 0){
	throw;}
	startsAt = _start;
	if(_end == 0){
	throw;}
	endsAt = _end;
	if(startsAt >= endsAt){
	throw;}
	minimumFundingGoal = _minimumFundingGoal;
	isUpdatable = _isUpdatable;
	isWhiteListed = _isWhiteListed;
	}
	function () payable public {
	throw;}
	function investInternal(address receiver, uint128 customerId) stopInEmergency private {
	if(getState() == State.PreFunding){
	throw;}
	else{
	if(getState() == State.Funding){
	if(isWhiteListed){
	if(! earlyParticipantWhitelist[receiver].status){
	throw;}
	}
	}
	else{
	throw;}
	}
	uint weiAmount = msg.value;
	uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised - presaleWeiRaised, tokensSold, msg.sender, token.decimals());
	if(tokenAmount == 0){
	throw;}
	if(isWhiteListed){
	if(tokenAmount < earlyParticipantWhitelist[receiver].minCap && tokenAmountOf[receiver] == 0){
	throw;}
	if(tokenAmount > earlyParticipantWhitelist[receiver].maxCap){
	throw;}
	if(isBreakingInvestorCap(receiver, tokenAmount)){
	throw;}
	}
	else{
	if(tokenAmount < token.minCap() && tokenAmountOf[receiver] == 0){
	throw;}
	}
	if(isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold)){
	throw;}
	investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);
	tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);
	weiRaised = weiRaised.plus(weiAmount);
	tokensSold = tokensSold.plus(tokenAmount);
	if(pricingStrategy.isPresalePurchase(receiver)){
	presaleWeiRaised = presaleWeiRaised.plus(weiAmount);
	}
	if(investedAmountOf[receiver] == 0){
	investorCount++;
	}
	assignTokens(receiver, tokenAmount);
	if(! multisigWallet.send(weiAmount)){
	throw;}
	if(isWhiteListed){
	uint num = 0;
	for(var i = 0;i < joinedCrowdsalesLen;i++){
	if(this == joinedCrowdsales[i]){
	num = i;
	}
	}
	if(num + 1 < joinedCrowdsalesLen){
	for(var j = num + 1;j < joinedCrowdsalesLen;j++){
	CrowdsaleExt crowdsale = CrowdsaleExt(joinedCrowdsales[j]);
	crowdsale.updateEarlyParicipantWhitelist(msg.sender, this, tokenAmount);
	}
	}
	}
	Invested(receiver, weiAmount, tokenAmount, customerId);
	}
	function preallocate(address receiver, uint fullTokens, uint weiPrice) onlyOwner public {
	uint tokenAmount = fullTokens * 10 ** token.decimals();
	uint weiAmount = weiPrice * fullTokens;
	weiRaised = weiRaised.plus(weiAmount);
	tokensSold = tokensSold.plus(tokenAmount);
	investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);
	tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);
	assignTokens(receiver, tokenAmount);
	Invested(receiver, weiAmount, tokenAmount, 0);
	}
	function investWithSignedAddress(address addr, uint128 customerId, uint8 v, bytes32 r, bytes32 s) payable public {
	bytes32 hash = sha256(addr);
	if(ecrecover(hash, v, r, s) != signerAddress){
	throw;}
	if(customerId == 0){
	throw;}
	investInternal(addr, customerId);
	}
	function investWithCustomerId(address addr, uint128 customerId) payable public {
	if(requiredSignedAddress){
	throw;}
	if(customerId == 0){
	throw;}
	investInternal(addr, customerId);
	}
	function invest(address addr) payable public {
	if(requireCustomerId){
	throw;}
	if(requiredSignedAddress){
	throw;}
	investInternal(addr, 0);
	}
	function buyWithSignedAddress(uint128 customerId, uint8 v, bytes32 r, bytes32 s) payable public {
	investWithSignedAddress(msg.sender, customerId, v, r, s);
	}
	function buyWithCustomerId(uint128 customerId) payable public {
	investWithCustomerId(msg.sender, customerId);
	}
	function buy() payable public {
	invest(msg.sender);
	}
	function finalize() inState(State.Success) onlyOwner stopInEmergency public {
	if(finalized){
	throw;}
	if(address(finalizeAgent) != 0){
	finalizeAgent.finalizeCrowdsale();
	}
	finalized = true;
	}
	function setFinalizeAgent(FinalizeAgent addr) onlyOwner public {
	finalizeAgent = addr;
	if(! finalizeAgent.isFinalizeAgent()){
	throw;}
	}
	function setRequireCustomerId(bool value) onlyOwner public {
	requireCustomerId = value;
	InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
	}
	function setRequireSignedAddress(bool value, address _signerAddress) onlyOwner public {
	requiredSignedAddress = value;
	signerAddress = _signerAddress;
	InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
	}
	function setEarlyParicipantWhitelist(address addr, bool status, uint minCap, uint maxCap) onlyOwner public {
	if(! isWhiteListed){
	throw;}
	earlyParticipantWhitelist[addr] = WhiteListData(status, minCap, maxCap);
	Whitelisted(addr, status);
	}
	function setEarlyParicipantsWhitelist(address[] addrs, bool[] statuses, uint[] minCaps, uint[] maxCaps) onlyOwner public {
	if(! isWhiteListed){
	throw;}
	for(uint iterator = 0;iterator < addrs.length;iterator++){
	setEarlyParicipantWhitelist(addrs[iterator], statuses[iterator], minCaps[iterator], maxCaps[iterator]);
	}
	}
	function updateEarlyParicipantWhitelist(address addr, address contractAddr, uint tokensBought) public {
	if(tokensBought < earlyParticipantWhitelist[addr].minCap){
	throw;}
	if(! isWhiteListed){
	throw;}
	if(addr != msg.sender && contractAddr != msg.sender){
	throw;}
	uint newMaxCap = earlyParticipantWhitelist[addr].maxCap;
	newMaxCap = newMaxCap.minus(tokensBought);
	earlyParticipantWhitelist[addr] = WhiteListData(earlyParticipantWhitelist[addr].status, 0, newMaxCap);
	}
	function updateJoinedCrowdsales(address addr) onlyOwner public {
	joinedCrowdsales[joinedCrowdsalesLen++] = addr;
	}
	function setLastCrowdsale(address addr) onlyOwner public {
	lastCrowdsale = addr;
	}
	function clearJoinedCrowdsales() onlyOwner public {
	joinedCrowdsalesLen = 0;
	}
	function updateJoinedCrowdsalesMultiple(address[] addrs) onlyOwner public {
	clearJoinedCrowdsales();
	for(uint iter = 0;iter < addrs.length;iter++){
	if(joinedCrowdsalesLen == joinedCrowdsales.length){
	joinedCrowdsales.length += 1;
	}
	joinedCrowdsales[joinedCrowdsalesLen++] = addrs[iter];
	if(iter == addrs.length - 1){
	setLastCrowdsale(addrs[iter]);
	}
	}
	}
	function setStartsAt(uint time) onlyOwner public {
	if(finalized){
	throw;}
	if(! isUpdatable){
	throw;}
	if(now > time){
	throw;}
	if(time > endsAt){
	throw;}
	CrowdsaleExt lastCrowdsaleCntrct = CrowdsaleExt(lastCrowdsale);
	if(lastCrowdsaleCntrct.finalized()){
	throw;}
	startsAt = time;
	StartsAtChanged(startsAt);
	}
	function setEndsAt(uint time) onlyOwner public {
	if(finalized){
	throw;}
	if(! isUpdatable){
	throw;}
	if(now > time){
	throw;}
	if(startsAt > time){
	throw;}
	CrowdsaleExt lastCrowdsaleCntrct = CrowdsaleExt(lastCrowdsale);
	if(lastCrowdsaleCntrct.finalized()){
	throw;}
	uint num = 0;
	for(var i = 0;i < joinedCrowdsalesLen;i++){
	if(this == joinedCrowdsales[i]){
	num = i;
	}
	}
	if(num + 1 < joinedCrowdsalesLen){
	for(var j = num + 1;j < joinedCrowdsalesLen;j++){
	CrowdsaleExt crowdsale = CrowdsaleExt(joinedCrowdsales[j]);
	if(time > crowdsale.startsAt()){
	throw;}
	}
	}
	endsAt = time;
	EndsAtChanged(endsAt);
	}
	function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner public {
	pricingStrategy = _pricingStrategy;
	if(! pricingStrategy.isPricingStrategy()){
	throw;}
	}
	function setMultisig(address addr) onlyOwner public {
	if(investorCount > MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE){
	throw;}
	multisigWallet = addr;
	}
	function refund() inState(State.Refunding) public {
	uint256 weiValue = investedAmountOf[msg.sender];
	if(weiValue == 0){
	throw;}
	investedAmountOf[msg.sender] = 0;
	weiRefunded = weiRefunded.plus(weiValue);
	Refund(msg.sender, weiValue);
	if(! msg.sender.send(weiValue)){
	throw;}
	}
	function isMinimumGoalReached() view public returns(bool reached){
	return weiRaised >= minimumFundingGoal;
	}
	function isFinalizerSane() view public returns(bool sane){
	return finalizeAgent.isSane();
	}
	function isPricingSane() view public returns(bool sane){
	return pricingStrategy.isSane(address(this));
	}
	function getState() view public returns(State ){
	if(finalized){
	return State.Finalized;
	}
	else{
	if(address(finalizeAgent) == 0){
	return State.Preparing;
	}
	else{
	if(! finalizeAgent.isSane()){
	return State.Preparing;
	}
	else{
	if(! pricingStrategy.isSane(address(this))){
	return State.Preparing;
	}
	else{
	if(block.timestamp < startsAt){
	return State.PreFunding;
	}
	else{
	if(block.timestamp <= endsAt && ! isCrowdsaleFull()){
	return State.Funding;
	}
	else{
	if(isMinimumGoalReached()){
	return State.Success;
	}
	else{
	if(! isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised){
	return State.Refunding;
	}
	else{
	return State.Failure;
	}
	}
	}
	}
	}
	}
	}
	}
	}
	function setOwnerTestValue(uint val) onlyOwner public {
	ownerTestValue = val;
	}
	function loadRefund() inState(State.Failure) payable public {
	if(msg.value == 0){
	throw;}
	loadedRefund = loadedRefund.plus(msg.value);
	}
	function isCrowdsale() view public returns(bool ){
	return true;
	}
	modifier inState(State state){
	if(getState() != state){
	throw;}
	_;}
	function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) view public returns(bool limitBroken);function isBreakingInvestorCap(address receiver, uint tokenAmount) view public returns(bool limitBroken);function isCrowdsaleFull() view public returns(bool );function assignTokens(address receiver, uint tokenAmount) private ;
}contract StandardToken is ERC20 , SafeMath {
	event Minted(address receiver, uint amount);
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;
	function isToken() view public returns(bool weAre){
	return true;
	}
	function transfer(address _to, uint _value) public returns(bool success){
	balances[msg.sender] = safeSub(balances[msg.sender], _value);
	balances[_to] = safeAdd(balances[_to], _value);
	Transfer(msg.sender, _to, _value);
	return true;
	}
	function transferFrom(address _from, address _to, uint _value) public returns(bool success){
	uint _allowance = allowed[_from][msg.sender];
	balances[_to] = safeAdd(balances[_to], _value);
	balances[_from] = safeSub(balances[_from], _value);
	allowed[_from][msg.sender] = safeSub(_allowance, _value);
	Transfer(_from, _to, _value);
	return true;
	}
	function balanceOf(address _owner) view public returns(uint balance){
	return balances[_owner];
	}
	function approve(address _spender, uint _value) public returns(bool success){
	if((_value != 0) && (allowed[msg.sender][_spender] != 0)){
	throw;}
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint remaining){
	return allowed[_owner][_spender];
	}
	
}contract MintableTokenExt is StandardToken , Ownable {
	using SafeMathLibExt for uint;
	bool public mintingFinished = false;
	mapping(address => bool) public mintAgents;
	event MintingAgentChanged(address addr, bool state);
	struct ReservedTokensData{
	uint inTokens;
	uint inPercentage;
	}
	mapping(address => ReservedTokensData) public reservedTokensList;
	address[] public reservedTokensDestinations;
	uint public reservedTokensDestinationsLen = 0;
	function setReservedTokensList(address addr, uint inTokens, uint inPercentage) onlyOwner public {
	reservedTokensDestinations.push(addr);
	reservedTokensDestinationsLen++;
	reservedTokensList[addr] = ReservedTokensData(inTokens, inPercentage);
	}
	function getReservedTokensListValInTokens(address addr) view public returns(uint inTokens){
	return reservedTokensList[addr].inTokens;
	}
	function getReservedTokensListValInPercentage(address addr) view public returns(uint inPercentage){
	return reservedTokensList[addr].inPercentage;
	}
	function setReservedTokensListMultiple(address[] addrs, uint[] inTokens, uint[] inPercentage) onlyOwner public {
	for(uint iterator = 0;iterator < addrs.length;iterator++){
	setReservedTokensList(addrs[iterator], inTokens[iterator], inPercentage[iterator]);
	}
	}
	function mint(address receiver, uint amount) onlyMintAgent canMint public {
	totalSupply = totalSupply.plus(amount);
	balances[receiver] = balances[receiver].plus(amount);
	Transfer(0, receiver, amount);
	}
	function setMintAgent(address addr, bool state) onlyOwner canMint public {
	mintAgents[addr] = state;
	MintingAgentChanged(addr, state);
	}
	modifier onlyMintAgent(){
	if(! mintAgents[msg.sender]){
	throw;}
	_;}
	modifier canMint(){
	if(mintingFinished){
	throw;}
	_;}
	
}contract MintedTokenCappedCrowdsaleExt is CrowdsaleExt {
	uint public maximumSellableTokens;
	constructor(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _maximumSellableTokens, bool _isUpdatable, bool _isWhiteListed) CrowdsaleExt(_token,_pricingStrategy,_multisigWallet,_start,_end,_minimumFundingGoal,_isUpdatable,_isWhiteListed) public {
	maximumSellableTokens = _maximumSellableTokens;
	}
	event MaximumSellableTokensChanged(uint newMaximumSellableTokens);
	function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) view public returns(bool limitBroken){
	return tokensSoldTotal > maximumSellableTokens;
	}
	function isBreakingInvestorCap(address addr, uint tokenAmount) view public returns(bool limitBroken){
	if(! isWhiteListed){
	throw;}
	uint maxCap = earlyParticipantWhitelist[addr].maxCap;
	return (tokenAmountOf[addr].plus(tokenAmount)) > maxCap;
	}
	function isCrowdsaleFull() view public returns(bool ){
	return tokensSold >= maximumSellableTokens;
	}
	function assignTokens(address receiver, uint tokenAmount) private {
	MintableTokenExt mintableToken = MintableTokenExt(token);
	mintableToken.mint(receiver, tokenAmount);
	}
	function setMaximumSellableTokens(uint tokens) onlyOwner public {
	if(finalized){
	throw;}
	if(! isUpdatable){
	throw;}
	CrowdsaleExt lastCrowdsaleCntrct = CrowdsaleExt(lastCrowdsale);
	if(lastCrowdsaleCntrct.finalized()){
	throw;}
	maximumSellableTokens = tokens;
	MaximumSellableTokensChanged(maximumSellableTokens);
	}
	
}