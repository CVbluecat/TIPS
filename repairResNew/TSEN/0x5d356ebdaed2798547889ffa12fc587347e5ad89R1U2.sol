pragma solidity ^0.4.15;
library SafeMath {
	function mul(uint256 a, uint256 b) view internal returns(uint256 ){
	uint256 c = a * b;
	assert(a == 0 || c / a == b);
	return c;
	}
	function div(uint256 a, uint256 b) view internal returns(uint256 ){
	uint256 c = a / b;
	return c;
	}
	function sub(uint256 a, uint256 b) view internal returns(uint256 ){
	assert(b <= a);
	return a - b;
	}
	function add(uint256 a, uint256 b) view internal returns(uint256 ){
	uint256 c = a + b;
	assert(c >= a);
	return c;
	}
	
}contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) view public returns(uint256 );function transfer(address to, uint256 value) public returns(bool );event Transfer(address indexed from, address indexed to, uint256 value);
	
}contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) view public returns(uint256 );function transferFrom(address from, address to, uint256 value) public returns(bool );function approve(address spender, uint256 value) public returns(bool );event Approval(address indexed owner, address indexed spender, uint256 value);
	
}contract BasicToken is ERC20Basic {
	using SafeMath for uint256;
	mapping(address => uint256) balances;
	function transfer(address _to, uint256 _value) public returns(bool ){
	require(_to != address(0));
	balances[msg.sender] = balances[msg.sender].sub(_value);
	balances[_to] = balances[_to].add(_value);
	Transfer(msg.sender, _to, _value);
	return true;
	}
	function balanceOf(address _owner) view public returns(uint256 balance){
	return balances[_owner];
	}
	
}contract StandardToken is ERC20 , BasicToken {
	mapping(address => mapping(address => uint256)) allowed;
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool ){
	require(_to != address(0));
	uint256 _allowance = allowed[_from][msg.sender];
	balances[_from] = balances[_from].sub(_value);
	balances[_to] = balances[_to].add(_value);
	allowed[_from][msg.sender] = _allowance.sub(_value);
	Transfer(_from, _to, _value);
	return true;
	}
	function approve(address _spender, uint256 _value) public returns(bool ){
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint256 remaining){
	return allowed[_owner][_spender];
	}
	function increaseApproval(address _spender, uint _addedValue) public returns(bool success){
	allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
	Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
	return true;
	}
	function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool success){
	uint oldValue = allowed[msg.sender][_spender];
	if(_subtractedValue > oldValue){
	allowed[msg.sender][_spender] = 0;
	}
	else{
	allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
	}
	Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
	return true;
	}
	
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
	
}contract MintableToken is StandardToken , Ownable {
	event Mint(address indexed to, uint256 amount);
	event MintFinished();
	bool public mintingFinished = false;
	modifier canMint(){
	require(! mintingFinished);
	_;}
	function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool ){
	totalSupply = totalSupply.add(_amount);
	balances[_to] = balances[_to].add(_amount);
	Mint(_to, _amount);
	Transfer(0x0, _to, _amount);
	return true;
	}
	function finishMinting() onlyOwner public returns(bool ){
	mintingFinished = true;
	MintFinished();
	return true;
	}
	
}contract BurnableToken is StandardToken {
	event Burn(address indexed burner, uint256 value);
	function burn(uint256 _value) public {
	require(_value > 0);
	address burner = msg.sender;
	balances[burner] = balances[burner].sub(_value);
	totalSupply = totalSupply.sub(_value);
	Burn(burner, _value);
	}
	
}contract Crowdsale {
	using SafeMath for uint256;
	MintableToken public token;
	uint256 public startTime;
	uint256 public endTime;
	address public wallet;
	uint256 public rate;
	uint256 public weiRaised;
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
	constructor(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token) public {
	require(_startTime >= now);
	require(_endTime >= _startTime);
	require(_rate > 0);
	require(_wallet != 0x0);
	token = createTokenContract(_token);
	startTime = _startTime;
	endTime = _endTime;
	rate = _rate;
	wallet = _wallet;
	}
	function createTokenContract(address tokenAddress) internal returns(MintableToken ){
	return MintableToken(tokenAddress);
	}
	function () payable public {
	buyTokens(msg.sender);
	}
	function buyTokens(address beneficiary) payable public {
	require(beneficiary != 0x0);
	require(validPurchase());
	uint256 weiAmount = msg.value;
	uint256 tokens = weiAmount.mul(rate);
	weiRaised = weiRaised.add(weiAmount);
	token.mint(beneficiary, tokens);
	TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
	forwardFunds();
	}
	function forwardFunds() internal {
	wallet.transfer(msg.value);
	}
	function validPurchase() view internal returns(bool ){
	bool withinPeriod = now >= startTime && now <= endTime;
	bool nonZeroPurchase = msg.value != 0;
	return withinPeriod && nonZeroPurchase;
	}
	function hasEnded() view public returns(bool ){
	return now > endTime;
	}
	
}contract FinalizableCrowdsale is Crowdsale , Ownable {
	using SafeMath for uint256;
	bool public isFinalized = false;
	event Finalized();
	function finalize() onlyOwner public {
	require(! isFinalized);
	require(hasEnded());
	finalization();
	Finalized();
	isFinalized = true;
	}
	function finalization() internal {
	}
	
}contract CappedCrowdsale is Crowdsale {
	using SafeMath for uint256;
	uint256 public cap;
	constructor(uint256 _cap) public {
	require(_cap > 0);
	cap = _cap;
	}
	function validPurchase() view internal returns(bool ){
	bool withinCap = weiRaised.add(msg.value) <= cap;
	return super.validPurchase() && withinCap;
	}
	function hasEnded() view public returns(bool ){
	bool capReached = weiRaised >= cap;
	return super.hasEnded() || capReached;
	}
	
}contract FortitudeRanchCrowdsale is FinalizableCrowdsale , CappedCrowdsale {
	constructor(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token) FinalizableCrowdsale CappedCrowdsale(150000000000000000000000) Crowdsale(_startTime,_endTime,_rate,_wallet,_token) public {
	}
	function buyTokens(address beneficiary) payable public {
	require(beneficiary != 0x0);
	require(validPurchase());
	uint256 weiAmount = msg.value;
	if(now < (startTime + 1 days)){
	uint256 discountRate = rate.mul(12000000);
	discountRate = discountRate.div(10000);
	uint256 tokens = weiAmount.mul(discountRate).div(1000 ether);
	}
	else{
	tokens = (weiAmount.mul(rate)).div(1 ether);
	}
	weiRaised = weiRaised.add(weiAmount);
	token.mint(beneficiary, tokens);
	TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
	forwardFunds();
	}
	function offChainMint(address beneficiary, uint256 tokenAmount) onlyOwner public {
	require(beneficiary != 0x0);
	bool withinCap = token.totalSupply().add(tokenAmount) <= cap;
	require(withinCap);
	token.mint(beneficiary, tokenAmount);
	TokenPurchase(msg.sender, beneficiary, 0, tokenAmount);
	}
	function validPurchase() view internal returns(bool ){
	require(msg.value >= 100000000000000000);
	if(now < (startTime + 1 days)){
	uint256 discountRate = rate.mul(12000000);
	discountRate = discountRate.div(10000);
	uint256 tokens = (msg.value).mul(discountRate).div(1000 ether);
	}
	else{
	tokens = (msg.value.mul(rate)).div(1 ether);
	}
	bool withinCap = token.totalSupply().add(tokens) <= cap;
	return super.validPurchase() && withinCap;
	}
	function hasEnded() view public returns(bool ){
	bool capReached = token.totalSupply() >= cap;
	return super.hasEnded() || capReached;
	}
	function finalization() internal {
	uint256 tokensAmount = token.totalSupply();
	tokensAmount = tokensAmount.mul(2);
	tokensAmount = tokensAmount.div(10);
	token.mint(0xE746Bb9d6Db2eBBF02c12E2f64D0dfa155377895, tokensAmount);
	token.finishMinting();
	super.finalization();
	}
	
}