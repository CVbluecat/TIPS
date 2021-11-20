pragma solidity ^0.4.15;
library QuickMafs {
	function mul(uint256 _a, uint256 _b) pure internal returns(uint256 ){
	uint256 c = _a * _b;
	assert(_a == 0 || c / _a == _b);
	return c;
	}
	function div(uint256 _a, uint256 _b) pure internal returns(uint256 ){
	assert(_b > 0);
	uint256 c = _a / _b;
	return c;
	}
	function sub(uint256 _a, uint256 _b) pure internal returns(uint256 ){
	assert(_b <= _a);
	return _a - _b;
	}
	function add(uint256 _a, uint256 _b) pure internal returns(uint256 ){
	uint256 c = _a + _b;
	assert(c >= _a);
	return c;
	}
	
}contract Ownable {
	address public owner;
	constructor() public {
	owner = msg.sender;
	}
	modifier onlyOwner(){
	require(msg.sender == owner);
	_;}
	function transferOwnership(address _newOwner) onlyOwner public {
	if(_newOwner != address(0)){
	owner = _newOwner;
	}
	}
	
}contract ERC20 {
	function totalSupply() view public returns(uint256 _totalSupply);function balanceOf(address _owner) view public returns(uint256 balance);function transfer(address _to, uint256 _amount) public returns(bool success);function transferFrom(address _from, address _to, uint256 _amount) public returns(bool success);function approve(address _spender, uint256 _amount) public returns(bool success);function allowance(address _owner, address _spender) view public returns(uint256 remaining);event Transfer(address indexed _from, address indexed _to, uint256 _amount);
	event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
	
}contract CTNToken is ERC20 , Ownable {
	using QuickMafs for uint256;
	string public constant SYMBOL = "CTN";
	string public constant NAME = "Crypto Trust Network";
	uint8 public constant DECIMALS = 18;
	uint256 totalTokens;
	uint256 initialSupply;
	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;
	bool tradable;
	address public vault;
	bool public mintingFinished = false;
	event Mint(address indexed _to, uint256 _value);
	event MintFinished();
	event TradableTokens();
	modifier isTradable(){
	require(tradable);
	_;}
	modifier canMint(){
	require(! mintingFinished);
	_;}
	constructor() public {
	initialSupply = 4500000 * 1 ether;
	totalTokens = initialSupply;
	tradable = false;
	vault = 0x6e794AAA2db51fC246b1979FB9A9849f53919D1E;
	balances[vault] = balances[vault].add(initialSupply);
	}
	function totalSupply() view public returns(uint256 totalAmount){
	totalAmount = totalTokens;
	}
	function baseSupply() view public returns(uint256 initialAmount){
	initialAmount = initialSupply;
	}
	function balanceOf(address _address) view public returns(uint256 balance){
	return balances[_address];
	}
	function transfer(address _to, uint256 _amount) isTradable public returns(bool ){
	balances[msg.sender] = balances[msg.sender].sub(_amount);
	balances[_to] = balances[_to].add(_amount);
	Transfer(msg.sender, _to, _amount);
	return true;
	}
	function transferFrom(address _from, address _to, uint256 _amount) isTradable public returns(bool success){
	var _allowance = allowed[_from][msg.sender];
	balances[_to] = balances[_to].add(_amount);
	balances[_from] = balances[_from].sub(_amount);
	allowed[_from][msg.sender] = _allowance.sub(_amount);
	Transfer(_from, _to, _amount);
	return true;
	}
	function approve(address _spender, uint256 _amount) public returns(bool ){
	require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
	allowed[msg.sender][_spender] = _amount;
	Approval(msg.sender, _spender, _amount);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint256 remaining){
	return allowed[_owner][_spender];
	}
	function makeTradable() onlyOwner public {
	tradable = true;
	TradableTokens();
	}
	function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool ){
	totalTokens = totalTokens.add(_amount);
	balances[_to] = balances[_to].add(_amount);
	Mint(_to, _amount);
	return true;
	}
	function finishMinting() onlyOwner public returns(bool ){
	mintingFinished = true;
	MintFinished();
	return true;
	}
	
}contract CTNTokenSale is Ownable {
	using QuickMafs for uint256;
	uint256 hardCap;
	uint256 softCap;
	uint256 bonusCap;
	uint256 tokensPerETH;
	uint256 public start = 1513360800;
	uint256 public end = 1516039200;
	uint256 public twoMonthsLater = 1521136800;
	CTNToken public token;
	address public vault;
	mapping(address => uint256) investments;
	event TokenSold(address recipient, uint256 etherAmount, uint256 ctnAmount, bool bonus);
	event PriceUpdated(uint256 amount);
	modifier isPreSale(){
	require(now < start);
	_;}
	modifier isSaleOn(){
	require(now >= start && now <= end);
	_;}
	modifier isSaleFinished(){
	bool hitHardCap = token.totalSupply().sub(token.baseSupply()) >= hardCap;
	require(now > end || hitHardCap);
	_;}
	modifier isTwoMonthsLater(){
	require(now > twoMonthsLater);
	_;}
	modifier isUnderHardCap(){
	bool underHard = token.totalSupply().sub(token.baseSupply()) <= hardCap;
	require(underHard);
	_;}
	modifier isOverSoftCap(){
	bool overSoft = token.totalSupply().sub(token.baseSupply()) >= softCap;
	require(overSoft);
	_;}
	modifier isUnderSoftCap(){
	bool underSoft = token.totalSupply().sub(token.baseSupply()) < softCap;
	require(underSoft);
	_;}
	constructor() public {
	hardCap = 10500000 * 1 ether;
	softCap = 500000 * 1 ether;
	bonusCap = 2000000 * 1 ether;
	tokensPerETH = 536;
	token = new CTNToken();
	vault = 0x6e794AAA2db51fC246b1979FB9A9849f53919D1E;
	}
	function updatePrice(uint256 _newPrice) onlyOwner isPreSale public {
	tokensPerETH = _newPrice;
	PriceUpdated(_newPrice);
	}
	function createTokens(address recipient) isUnderHardCap isSaleOn payable public {
	uint256 amount = msg.value;
	uint256 tokens = tokensPerETH.mul(amount);
	bool bonus = false;
	if(token.totalSupply().sub(token.baseSupply()) < bonusCap){
	bonus = true;
	tokens = tokens.add(tokens.div(5));
	}
	investments[msg.sender] = investments[msg.sender].add(msg.value);
	if(! token.mint(recipient, tokens)){
	throw;}
	TokenSold(recipient, amount, tokens, bonus);
	}
	function cleanup() isTwoMonthsLater public {
	vault.transfer(this.balance);
	if(! token.finishMinting()){
	throw;}
	token.makeTradable();
	}
	function destroy() onlyOwner isTwoMonthsLater public {
	if(! token.finishMinting()){
	throw;}
	token.makeTradable();
	token.transferOwnership(owner);
	selfdestruct(vault);
	}
	function withdrawl() isSaleFinished isOverSoftCap public {
	vault.transfer(this.balance);
	if(! token.finishMinting()){
	throw;}
	token.makeTradable();
	}
	function refund() isSaleFinished isUnderSoftCap public {
	uint256 amount = investments[msg.sender];
	investments[msg.sender] = investments[msg.sender].sub(amount);
	msg.sender.transfer(amount);
	}
	function getBalance() view public returns(uint256 totalAmount){
	totalAmount = this.balance;
	}
	function () payable external {
	createTokens(msg.sender);
	}
	
}