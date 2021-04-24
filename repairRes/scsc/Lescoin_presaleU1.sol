pragma solidity ^0.4.11;
contract ERC20 {
	uint public totalSupply;
	function balanceOf(address who) view public returns(uint );function allowance(address owner, address spender) view public returns(uint );function transfer(address to, uint value) public returns(bool ok);function transferFrom(address from, address to, uint value) public returns(bool ok);function approve(address spender, uint value) public returns(bool ok);event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	
}contract ContractReceiver {
	function tokenFallback(address from, uint value) public ;
}contract SafeMath {
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
	function assert(bool assertion) internal {
	if(! assertion){
	revert();
	}
	}
	
}contract StandardToken is ERC20 , SafeMath {
	event Minted(address receiver, uint amount);
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;
	modifier onlyPayloadSize(uint size){
	if(msg.data.length != size + 4){
	revert();
	}
	_;}
	function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public returns(bool success){
	balances[msg.sender] = safeSub(balances[msg.sender], _value);
	balances[_to] = safeAdd(balances[_to], _value);
	Transfer(msg.sender, _to, _value);
	if(isContract(_to)){
	ContractReceiver rx = ContractReceiver(_to);
	rx.tokenFallback(msg.sender, _value);
	}
	return true;
	}
	function isContract(address _addr) private returns(bool ){
	uint length;
	_addr = _addr;
	assembly{
    length := extcodesize(_addr)
}return (length > 0);
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
	revert();
	}
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint remaining){
	return allowed[_owner][_spender];
	}
	function addApproval(address _spender, uint _addedValue) onlyPayloadSize(2 * 32) public returns(bool success){
	uint oldValue = allowed[msg.sender][_spender];
	allowed[msg.sender][_spender] = safeAdd(oldValue, _addedValue);
	Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
	return true;
	}
	function subApproval(address _spender, uint _subtractedValue) onlyPayloadSize(2 * 32) public returns(bool success){
	uint oldVal = allowed[msg.sender][_spender];
	if(_subtractedValue > oldVal){
	allowed[msg.sender][_spender] = 0;
	}
	else{
	allowed[msg.sender][_spender] = safeSub(oldVal, _subtractedValue);
	}
	Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
	return true;
	}
	
}contract BurnableToken is StandardToken {
	address public constant BURN_ADDRESS = 0;
	event Burned(address burner, uint burnedAmount);
	function burn(uint burnAmount) public {
	address burner = msg.sender;
	balances[burner] = safeSub(balances[burner], burnAmount);
	totalSupply = safeSub(totalSupply, burnAmount);
	Burned(burner, burnAmount);
	}
	
}contract UpgradeAgent {
	uint public originalSupply;
	function isUpgradeAgent() view public returns(bool ){
	return true;
	}
	function upgradeFrom(address _from, uint256 _value) public ;
}contract UpgradeableToken is StandardToken {
	address public upgradeMaster;
	UpgradeAgent public upgradeAgent;
	uint256 public totalUpgraded;
	enum UpgradeState{
	Unknown,
	NotAllowed,
	WaitingForAgent,
	ReadyToUpgrade,
	Upgrading}
	event Upgrade(address indexed _from, address indexed _to, uint256 _value);
	event UpgradeAgentSet(address agent);
	constructor(address _upgradeMaster) public {
	upgradeMaster = _upgradeMaster;
	}
	function upgrade(uint256 value) public {
	UpgradeState state = getUpgradeState();
	if(! (state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)){
	revert();
	}
	if(value == 0){
	revert();
	}
	balances[msg.sender] = safeSub(balances[msg.sender], value);
	totalSupply = safeSub(totalSupply, value);
	totalUpgraded = safeAdd(totalUpgraded, value);
	upgradeAgent.upgradeFrom(msg.sender, value);
	Upgrade(msg.sender, upgradeAgent, value);
	}
	function setUpgradeAgent(address agent) external {
	if(! canUpgrade()){
	revert();
	}
	if(agent == 0x0){
	revert();
	}
	if(msg.sender != upgradeMaster){
	revert();
	}
	if(getUpgradeState() == UpgradeState.Upgrading){
	revert();
	}
	upgradeAgent = UpgradeAgent(agent);
	if(! upgradeAgent.isUpgradeAgent()){
	revert();
	}
	if(upgradeAgent.originalSupply() != totalSupply){
	revert();
	}
	UpgradeAgentSet(upgradeAgent);
	}
	function getUpgradeState() view public returns(UpgradeState ){
	if(! canUpgrade()){
	return UpgradeState.NotAllowed;
	}
	else{
	if(address(upgradeAgent) == 0x00){
	return UpgradeState.WaitingForAgent;
	}
	else{
	if(totalUpgraded == 0){
	return UpgradeState.ReadyToUpgrade;
	}
	else{
	return UpgradeState.Upgrading;
	}
	}
	}
	}
	function setUpgradeMaster(address master) public {
	if(master == 0x0){
	revert();
	}
	if(msg.sender != upgradeMaster){
	revert();
	}
	upgradeMaster = master;
	}
	function canUpgrade() view public returns(bool ){
	return true;
	}
	
}contract BCOExtendedToken is BurnableToken , UpgradeableToken {
	string public name;
	string public symbol;
	uint public decimals;
	address public owner;
	bool public mintingFinished = false;
	mapping(address => uint) public previligedBalances;
	mapping(address => bool) public mintAgents;
	event MintingAgentChanged(address addr, bool state);
	modifier onlyOwner(){
	if(msg.sender != owner){
	revert();
	}
	_;}
	modifier onlyMintAgent(){
	if(! mintAgents[msg.sender]){
	revert();
	}
	_;}
	modifier canMint(){
	if(mintingFinished){
	revert();
	}
	_;}
	function transferOwnership(address newOwner) onlyOwner public {
	if(newOwner != address(0)){
	owner = newOwner;
	}
	}
	constructor(address _owner, string _name, string _symbol, uint _totalSupply, uint _decimals) UpgradeableToken(_owner) public {
	name = _name;
	symbol = _symbol;
	totalSupply = _totalSupply;
	decimals = _decimals;
	balances[_owner] = _totalSupply;
	owner = _owner;
	}
	function transferPrivileged(address _to, uint _value) onlyOwner public returns(bool success){
	balances[msg.sender] = safeSub(balances[msg.sender], _value);
	balances[_to] = safeAdd(balances[_to], _value);
	previligedBalances[_to] = safeAdd(previligedBalances[_to], _value);
	Transfer(msg.sender, _to, _value);
	return true;
	}
	function getPrivilegedBalance(address _owner) view public returns(uint balance){
	return previligedBalances[_owner];
	}
	function transferFromPrivileged(address _from, address _to, uint _value) onlyOwner public returns(bool success){
	uint availablePrevilegedBalance = previligedBalances[_from];
	balances[_from] = safeSub(balances[_from], _value);
	balances[_to] = safeAdd(balances[_to], _value);
	previligedBalances[_from] = safeSub(availablePrevilegedBalance, _value);
	Transfer(_from, _to, _value);
	return true;
	}
	function mint(address receiver, uint amount) onlyMintAgent canMint public {
	totalSupply = safeAdd(totalSupply, amount);
	balances[receiver] = safeAdd(balances[receiver], amount);
	Transfer(0, receiver, amount);
	}
	function setMintAgent(address addr, bool state) onlyOwner canMint public {
	mintAgents[addr] = state;
	MintingAgentChanged(addr, state);
	}
	
}contract SaleExtendedBCO {
	address public beneficiary;
	uint public startline;
	uint public deadline;
	uint public price;
	uint public amountRaised;
	uint public incomingTokensTransactions;
	mapping(address => uint) public actualGotETH;
	BCOExtendedToken public tokenReward;
	event TokenFallback(address indexed from, uint256 value);
	modifier onlyOwner(){
	if(msg.sender != beneficiary){
	revert();
	}
	_;}
	modifier whenCrowdsaleIsFinished(){
	if(now < deadline){
	revert();
	}
	_;}
	modifier whenRefundAvailable(){
	if(tokenReward.balanceOf(address(this)) <= 0){
	revert();
	}
	_;}
	constructor(uint start, uint end, uint costOfEachToken, BCOExtendedToken addressOfTokenUsedAsReward) public {
	beneficiary = msg.sender;
	startline = start;
	deadline = end;
	price = costOfEachToken;
	tokenReward = BCOExtendedToken(addressOfTokenUsedAsReward);
	}
	function () payable public {
	if(now <= startline){
	revert();
	}
	if(now >= deadline){
	revert();
	}
	uint amount = msg.value;
	if(amount < price){
	revert();
	}
	amountRaised += amount;
	uint tokensToSend = amount / price;
	actualGotETH[msg.sender] += amount;
	if(! tokenReward.transfer(msg.sender, tokensToSend)){
	throw;}
	}
	function transferOwnership(address newOwner) onlyOwner public {
	if(newOwner != address(0)){
	beneficiary = newOwner;
	}
	}
	function Refund() whenRefundAvailable whenCrowdsaleIsFinished public {
	msg.sender.transfer(actualGotETH[msg.sender]);
	}
	function WithdrawETH(uint amount) onlyOwner public {
	beneficiary.transfer(amount);
	}
	function WithdrawAllETH() onlyOwner public {
	beneficiary.transfer(amountRaised);
	}
	function WithdrawTokens(uint amount) onlyOwner public {
	if(! tokenReward.transfer(beneficiary, amount)){
	throw;}
	}
	function ChangeCost(uint costOfEachToken) onlyOwner public {
	price = costOfEachToken;
	}
	function ChangeStart(uint start) onlyOwner public {
	startline = start;
	}
	function ChangeEnd(uint end) onlyOwner public {
	deadline = end;
	}
	function tokenFallback(address from, uint value) public {
	incomingTokensTransactions += 1;
	TokenFallback(from, value);
	}
	
}