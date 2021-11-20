pragma solidity >=0.4.4;
contract Sale {
	uint public startTime;
	uint public stopTime;
	uint public target;
	uint public raised;
	uint public collected;
	uint public numContributors;
	mapping(address => uint) public balances;
	function buyTokens(address _a, uint _eth, uint _time) public returns(uint );function getTokens(address holder) view public returns(uint );function getRefund(address holder) view public returns(uint );function getSoldTokens() view public returns(uint );function getOwnerEth() view public returns(uint );function tokensPerEth() view public returns(uint );function isActive(uint time) view public returns(bool );function isComplete(uint time) view public returns(bool );
}contract Constants {
	uint DECIMALS = 8;
	
}contract EventDefinitions {
	event logSaleStart(uint startTime, uint stopTime);
	event logPurchase(address indexed purchaser, uint eth);
	event logClaim(address indexed purchaser, uint refund, uint tokens);
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	
}contract Testable {
	uint fakeTime;
	bool public testing;
	modifier onlyTesting(){
	if(! testing){
	throw;}
	_;}
	function setFakeTime(uint t) onlyTesting public {
	fakeTime = t;
	}
	function addMinutes(uint m) onlyTesting public {
	fakeTime = fakeTime + (m * 1 minutes);
	}
	function addDays(uint d) onlyTesting public {
	fakeTime = fakeTime + (d * 1 days);
	}
	function currTime() view public returns(uint ){
	if(testing){
	return fakeTime;
	}
	else{
	return block.timestamp;
	}
	}
	function weiPerEth() view public returns(uint ){
	if(testing){
	return 200;
	}
	else{
	return 10 ** 18;
	}
	}
	
}contract Owned {
	address public owner;
	modifier onlyOwner(){
	if(msg.sender != owner){
	throw;}
	_;}
	address newOwner;
	function changeOwner(address _newOwner) onlyOwner public {
	newOwner = _newOwner;
	}
	function acceptOwnership() public {
	if(msg.sender == newOwner){
	owner = newOwner;
	}
	}
	
}contract SafeMath {
	function safeMul(uint a, uint b) internal returns(uint ){
	uint c = a * b;
	assert(a == 0 || c / a == b);
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
	function assert(bool assertion) internal {
	if(! assertion){
	throw;}
	}
	
}contract Token is SafeMath , Owned , Constants {
	uint public totalSupply;
	address ico;
	address controller;
	string public name;
	uint8 public decimals;
	string public symbol;
	modifier onlyControllers(){
	if(msg.sender != ico && msg.sender != controller){
	throw;}
	_;}
	modifier onlyPayloadSize(uint numwords){
	assert(msg.data.length == numwords * 32 + 4);
	_;}
	constructor() public {
	owner = msg.sender;
	name = "Monolith TKN";
	decimals = uint8(DECIMALS);
	symbol = "TKN";
	}
	function setICO(address _ico) onlyOwner public {
	if(ico != 0){
	throw;}
	ico = _ico;
	}
	function setController(address _controller) onlyOwner public {
	if(controller != 0){
	throw;}
	controller = _controller;
	}
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	event Mint(address owner, uint amount);
	function mint(address addr, uint amount) onlyControllers public {
	if(maxSupply > 0 && safeAdd(totalSupply, amount) > maxSupply){
	throw;}
	balanceOf[addr] = safeAdd(balanceOf[addr], amount);
	totalSupply = safeAdd(totalSupply, amount);
	Mint(addr, amount);
	}
	mapping(address => uint) public balanceOf;
	mapping(address => mapping(address => uint)) public allowance;
	function transfer(address _to, uint _value) onlyPayloadSize(2) public returns(bool success){
	if(balanceOf[msg.sender] < _value){
	return false;
	}
	balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
	balanceOf[_to] = safeAdd(balanceOf[_to], _value);
	Transfer(msg.sender, _to, _value);
	return true;
	}
	function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3) public returns(bool success){
	if(balanceOf[_from] < _value){
	return false;
	}
	var allowed = allowance[_from][msg.sender];
	if(allowed < _value){
	return false;
	}
	balanceOf[_to] = safeAdd(balanceOf[_to], _value);
	balanceOf[_from] = safeSub(balanceOf[_from], _value);
	allowance[_from][msg.sender] = safeSub(allowed, _value);
	Transfer(_from, _to, _value);
	return true;
	}
	function approve(address _spender, uint _value) onlyPayloadSize(2) public returns(bool success){
	if((_value != 0) && (allowance[msg.sender][_spender] != 0)){
	return false;
	}
	allowance[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function increaseApproval(address _spender, uint _addedValue) onlyPayloadSize(2) public returns(bool success){
	uint oldValue = allowance[msg.sender][_spender];
	allowance[msg.sender][_spender] = safeAdd(oldValue, _addedValue);
	return true;
	}
	function decreaseApproval(address _spender, uint _subtractedValue) onlyPayloadSize(2) public returns(bool success){
	uint oldValue = allowance[msg.sender][_spender];
	if(_subtractedValue > oldValue){
	allowance[msg.sender][_spender] = 0;
	}
	else{
	allowance[msg.sender][_spender] = safeSub(oldValue, _subtractedValue);
	}
	return true;
	}
	TokenHolder tokenholder;
	bool lockedTokenHolder;
	function lockTokenHolder() onlyOwner public {
	lockedTokenHolder = true;
	}
	function setTokenHolder(address _th) onlyOwner public {
	if(lockedTokenHolder){
	throw;}
	tokenholder = TokenHolder(_th);
	}
	event Burn(address burner, uint amount);
	function burn(uint _amount) public returns(bool result){
	if(_amount > balanceOf[msg.sender]){
	return false;
	}
	balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _amount);
	totalSupply = safeSub(totalSupply, _amount);
	result = tokenholder.burn(msg.sender, _amount);
	if(! result){
	throw;}
	Burn(msg.sender, _amount);
	}
	uint public maxSupply;
	function setMaxSupply(uint _maxSupply) public {
	if(msg.sender != controller){
	throw;}
	if(maxSupply > 0){
	throw;}
	maxSupply = _maxSupply;
	}
	
}contract TokenHolder {
	function burn(address _burner, uint _amount) public returns(bool result){
	return false;
	}
	
}contract ICO is EventDefinitions , Testable , SafeMath , Owned {
	Token public token;
	address public controller;
	address public payee;
	Sale[] public sales;
	mapping(uint => uint) saleMinimumPurchases;
	mapping(address => uint) public nextClaim;
	mapping(address => uint) refundInStop;
	modifier tokenIsSet(){
	if(address(token) == 0){
	throw;}
	_;}
	modifier onlyController(){
	if(msg.sender != address(controller)){
	throw;}
	_;}
	constructor() public {
	owner = msg.sender;
	payee = msg.sender;
	allStopper = msg.sender;
	}
	function changePayee(address newPayee) onlyOwner notAllStopped public {
	payee = newPayee;
	}
	function setToken(address _token) onlyOwner public {
	if(address(token) != 0x0){
	throw;}
	token = Token(_token);
	}
	function setAsTest() onlyOwner public {
	if(sales.length == 0){
	testing = true;
	}
	}
	function setController(address _controller) onlyOwner notAllStopped public {
	if(address(controller) != 0x0){
	throw;}
	controller = _controller;
	}
	function addSale(address sale, uint minimumPurchase) onlyController notAllStopped public {
	uint salenum = sales.length;
	sales.push(Sale(sale));
	saleMinimumPurchases[salenum] = minimumPurchase;
	logSaleStart(Sale(sale).startTime(), Sale(sale).stopTime());
	}
	function addSale(address sale) onlyController public {
	addSale(sale, 0);
	}
	function getCurrSale() view public returns(uint ){
	if(sales.length == 0){
	throw;}
	return sales.length - 1;
	}
	function currSaleActive() view public returns(bool ){
	return sales[getCurrSale()].isActive(currTime());
	}
	function currSaleComplete() view public returns(bool ){
	return sales[getCurrSale()].isComplete(currTime());
	}
	function numSales() view public returns(uint ){
	return sales.length;
	}
	function numContributors(uint salenum) view public returns(uint ){
	return sales[salenum].numContributors();
	}
	event logPurchase(address indexed purchaser, uint value);
	function () payable public {
	deposit();
	}
	function deposit() notAllStopped payable public {
	doDeposit(msg.sender, msg.value);
	uint contrib = refundInStop[msg.sender];
	refundInStop[msg.sender] = contrib + msg.value;
	logPurchase(msg.sender, msg.value);
	}
	function doDeposit(address _for, uint _value) private {
	uint currSale = getCurrSale();
	if(! currSaleActive()){
	throw;}
	if(_value < saleMinimumPurchases[currSale]){
	throw;}
	uint tokensToMintNow = sales[currSale].buyTokens(_for, _value, currTime());
	if(tokensToMintNow > 0){
	token.mint(_for, tokensToMintNow);
	}
	}
	event logPurchaseViaToken(address indexed purchaser, address indexed token, uint depositedTokens, uint ethValue, bytes32 _reference);
	event logPurchaseViaFiat(address indexed purchaser, uint ethValue, bytes32 _reference);
	mapping(bytes32 => bool) public mintRefs;
	mapping(address => uint) public raisedFromToken;
	uint public raisedFromFiat;
	function depositFiat(address _for, uint _ethValue, bytes32 _reference) notAllStopped onlyOwner public {
	if(getCurrSale() > 0){
	throw;}
	if(mintRefs[_reference]){
	throw;}
	mintRefs[_reference] = true;
	raisedFromFiat = safeAdd(raisedFromFiat, _ethValue);
	doDeposit(_for, _ethValue);
	logPurchaseViaFiat(_for, _ethValue, _reference);
	}
	function depositTokens(address _for, address _token, uint _ethValue, uint _depositedTokens, bytes32 _reference) notAllStopped onlyOwner public {
	if(getCurrSale() > 0){
	throw;}
	if(mintRefs[_reference]){
	throw;}
	mintRefs[_reference] = true;
	raisedFromToken[_token] = safeAdd(raisedFromToken[_token], _ethValue);
	uint tokensPerEth = sales[0].tokensPerEth();
	uint tkn = safeMul(_ethValue, tokensPerEth) / weiPerEth();
	token.mint(_for, tkn);
	logPurchaseViaToken(_for, _token, _depositedTokens, _ethValue, _reference);
	}
	function safebalance(uint bal) private returns(uint ){
	if(bal > this.balance){
	return this.balance;
	}
	else{
	return bal;
	}
	}
	uint public topUpAmount;
	function topUp() onlyOwner notAllStopped payable public {
	topUpAmount = safeAdd(topUpAmount, msg.value);
	}
	function withdrawTopUp() onlyOwner notAllStopped public {
	uint amount = topUpAmount;
	topUpAmount = 0;
	if(! msg.sender.call.value(safebalance(amount))()){
	throw;}
	}
	function claim() notAllStopped public {
	var (tokens, refund, nc) = claimable(msg.sender, true);
	nextClaim[msg.sender] = nc;
	logClaim(msg.sender, refund, tokens);
	if(tokens > 0){
	token.mint(msg.sender, tokens);
	}
	if(refund > 0){
	refundInStop[msg.sender] = safeSub(refundInStop[msg.sender], refund);
	if(! msg.sender.send(safebalance(refund))){
	throw;}
	}
	}
	function claimFor(address _from, address _to) onlyOwner notAllStopped public {
	var (tokens, refund, nc) = claimable(_from, false);
	nextClaim[_from] = nc;
	logClaim(_from, refund, tokens);
	if(tokens > 0){
	token.mint(_to, tokens);
	}
	if(refund > 0){
	refundInStop[_from] = safeSub(refundInStop[_from], refund);
	if(! _to.send(safebalance(refund))){
	throw;}
	}
	}
	function claimable(address _a, bool _includeRecent) tokenIsSet view private returns(uint tokens, uint refund, uint nc){
	nc = nextClaim[_a];
	while(nc < sales.length && sales[nc].isComplete(currTime()) && (_includeRecent || sales[nc].stopTime() + 1 years < currTime())){
	refund = safeAdd(refund, sales[nc].getRefund(_a));
	tokens = safeAdd(tokens, sales[nc].getTokens(_a));
	nc += 1;
	}
	}
	function claimableTokens(address a) view public returns(uint ){
	var (tokens, refund, nc) = claimable(a, true);
	return tokens;
	}
	function claimableRefund(address a) view public returns(uint ){
	var (tokens, refund, nc) = claimable(a, true);
	return refund;
	}
	function claimableTokens() view public returns(uint ){
	return claimableTokens(msg.sender);
	}
	function claimableRefund() view public returns(uint ){
	return claimableRefund(msg.sender);
	}
	mapping(uint => bool) ownerClaimed;
	function claimableOwnerEth(uint salenum) view public returns(uint ){
	uint time = currTime();
	if(! sales[salenum].isComplete(time)){
	return 0;
	}
	return sales[salenum].getOwnerEth();
	}
	function claimOwnerEth(uint salenum) onlyOwner notAllStopped public {
	if(ownerClaimed[salenum]){
	throw;}
	uint ownereth = claimableOwnerEth(salenum);
	if(ownereth > 0){
	ownerClaimed[salenum] = true;
	if(! payee.call.value(safebalance(ownereth))()){
	throw;}
	}
	}
	event logTokenTransfer(address token, address to, uint amount);
	function transferTokens(address _token, address _to) onlyOwner public {
	Token token = Token(_token);
	uint balance = token.balanceOf(this);
	if(! token.transfer(_to, balance)){
	throw;}
	logTokenTransfer(_token, _to, balance);
	}
	bool allstopped;
	bool permastopped;
	address allStopper;
	function setAllStopper(address _a) onlyOwner public {
	if(allStopper != owner){
	return ;
	}
	allStopper = _a;
	}
	modifier onlyAllStopper(){
	if(msg.sender != allStopper){
	throw;}
	_;}
	event logAllStop();
	event logAllStart();
	modifier allStopped(){
	if(! allstopped){
	throw;}
	_;}
	modifier notAllStopped(){
	if(allstopped){
	throw;}
	_;}
	function allStop() onlyAllStopper public {
	allstopped = true;
	logAllStop();
	}
	function allStart() onlyAllStopper public {
	if(! permastopped){
	allstopped = false;
	logAllStart();
	}
	}
	function emergencyRefund(address _a, uint _amt) allStopped onlyAllStopper public {
	permastopped = true;
	uint amt = _amt;
	uint ethbal = refundInStop[_a];
	if(amt == 0){
	amt = ethbal;
	}
	if(amt > ethbal){
	amt = ethbal;
	}
	if(! _a.call.value(safebalance(amt))()){
	throw;}
	}
	function raised() view public returns(uint ){
	return sales[getCurrSale()].raised();
	}
	function tokensPerEth() view public returns(uint ){
	return sales[getCurrSale()].tokensPerEth();
	}
	
}