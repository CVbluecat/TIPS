pragma solidity ^0.4.11;
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
	
}contract ERC20 {
	uint public totalSupply;
	function balanceOf(address who) view public returns(uint );function allowance(address owner, address spender) view public returns(uint );function transfer(address to, uint value) public returns(bool ok);function transferFrom(address from, address to, uint value) public returns(bool ok);function approve(address spender, uint value) public returns(bool ok);event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	
}contract Ownable {
	address public owner;
	constructor() public {
	owner = msg.sender;
	}
	function transferOwnership(address newOwner) onlyOwner public {
	if(newOwner != address(0)){
	owner = newOwner;
	}
	}
	function kill() public {
	if(msg.sender == owner){
	selfdestruct(owner);
	}
	}
	modifier onlyOwner(){
	if(msg.sender == owner){
	_;}
	}
	
}contract Pausable is Ownable {
	bool public stopped;
	modifier stopInEmergency(){
	if(stopped){
	revert();
	}
	_;}
	modifier onlyInEmergency(){
	if(! stopped){
	revert();
	}
	_;}
	function emergencyStop() onlyOwner external {
	stopped = true;
	}
	function release() onlyOwner onlyInEmergency external {
	stopped = false;
	}
	
}contract PullPayment {
	mapping(address => uint) public payments;
	event RefundETH(address to, uint value);
	function asyncSend(address dest, uint amount) internal {
	payments[dest] += amount;
	}
	function withdrawPayments() internal returns(bool ){
	address payee = msg.sender;
	uint payment = payments[payee];
	if(payment == 0){
	revert();
	}
	if(this.balance < payment){
	revert();
	}
	payments[payee] = 0;
	if(! payee.send(payment)){
	revert();
	}
	RefundETH(payee, payment);
	return true;
	}
	
}contract Crowdsale is SafeMath , Pausable , PullPayment {
	struct Backer{
	uint weiReceived;
	uint GXCSent;
	}
	GXC public gxc;
	address public multisigETH;
	address public team;
	uint public ETHReceived;
	uint public GXCSentToETH;
	uint public startBlock;
	uint public endBlock;
	uint public maxCap;
	uint public minCap;
	uint public minInvestETH;
	bool public crowdsaleClosed;
	uint public tokenPriceWei;
	uint GXCReservedForPresale;
	uint multiplier = 10000000000;
	mapping(address => Backer) public backers;
	address[] public backersIndex;
	modifier respectTimeFrame(){
	if((block.number < startBlock) || (block.number > endBlock)){
	revert();
	}
	_;}
	modifier minCapNotReached(){
	if(GXCSentToETH >= minCap){
	revert();
	}
	_;}
	event ReceivedETH(address backer, uint amount, uint tokenAmount);
	constructor() public {
	multisigETH = 0x62739Ec09cdD8FAe2f7b976f8C11DbE338DF8750;
	team = 0x62739Ec09cdD8FAe2f7b976f8C11DbE338DF8750;
	GXCSentToETH = 487000 * multiplier;
	minInvestETH = 100000000000000000;
	startBlock = 0;
	endBlock = 0;
	maxCap = 8250000 * multiplier;
	tokenPriceWei = 3004447000000000;
	minCap = 500000 * multiplier;
	}
	function updateTokenAddress(GXC _GXCAddress) onlyOwner public returns(bool res){
	gxc = _GXCAddress;
	return true;
	}
	function updateTeamAddress(address _teamAddress) onlyOwner public returns(bool ){
	team = _teamAddress;
	return true;
	}
	function numberOfBackers() view public returns(uint ){
	return backersIndex.length;
	}
	function () payable public {
	handleETH(msg.sender);
	}
	function start(uint _block) onlyOwner public {
	startBlock = block.number;
	endBlock = startBlock + _block;
	crowdsaleClosed = false;
	}
	function handleETH(address _backer) stopInEmergency respectTimeFrame internal returns(bool res){
	if(msg.value < minInvestETH){
	revert();
	}
	uint GXCToSend = (msg.value * multiplier) / tokenPriceWei;
	if(safeAdd(GXCSentToETH, GXCToSend) > maxCap){
	revert();
	}
	Backer storage backer = backers[_backer];
	if(backer.weiReceived == 0){
	backersIndex.push(_backer);
	}
	ETHReceived = safeAdd(ETHReceived, msg.value);
	GXCSentToETH = safeAdd(GXCSentToETH, GXCToSend);
	if(! gxc.transfer(_backer, GXCToSend)){
	revert();
	}
	backer.GXCSent = safeAdd(backer.GXCSent, GXCToSend);
	backer.weiReceived = safeAdd(backer.weiReceived, msg.value);
	ReceivedETH(_backer, msg.value, GXCToSend);
	return true;
	}
	function finalize() onlyOwner public {
	if(crowdsaleClosed){
	revert();
	}
	uint daysToRefund = 4 * 60 * 24 * 10;
	if(block.number < endBlock && GXCSentToETH < maxCap - 100){
	revert();
	}
	if(GXCSentToETH < minCap && block.number < safeAdd(endBlock, daysToRefund)){
	revert();
	}
	if(GXCSentToETH > minCap){
	if(! multisigETH.send(this.balance)){
	revert();
	}
	gxc.unlock();
	if(! gxc.transfer(team, gxc.balanceOf(this))){
	revert();
	}
	}
	else{
	if(! gxc.burn(this, gxc.balanceOf(this))){
	revert();
	}
	}
	crowdsaleClosed = true;
	}
	function drain() onlyOwner public {
	if(! owner.send(this.balance)){
	revert();
	}
	}
	function transferDevTokens(address _devAddress) onlyOwner public returns(bool ){
	if(! gxc.transfer(_devAddress, gxc.balanceOf(this))){
	revert();
	}
	return true;
	}
	function prepareRefund() minCapNotReached internal returns(bool ){
	uint value = backers[msg.sender].GXCSent;
	if(value == 0){
	revert();
	}
	uint ETHToSend = backers[msg.sender].weiReceived;
	backers[msg.sender].weiReceived = 0;
	backers[msg.sender].GXCSent = 0;
	if(! gxc.burn(msg.sender, value)){
	revert();
	}
	if(ETHToSend > 0){
	asyncSend(msg.sender, ETHToSend);
	return true;
	}
	else{
	return false;
	}
	}
	function refund() public returns(bool ){
	if(! prepareRefund()){
	revert();
	}
	if(! withdrawPayments()){
	revert();
	}
	return true;
	}
	
}contract GXC is ERC20 , SafeMath , Ownable {
	string public name;
	string public symbol;
	uint8 public decimals;
	string public version = "v0.1";
	uint public initialSupply;
	uint public totalSupply;
	bool public locked;
	address public crowdSaleAddress;
	uint multiplier = 10000000000;
	uint256 public totalMigrated;
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;
	modifier onlyUnlocked(){
	if(msg.sender != crowdSaleAddress && locked && msg.sender != owner){
	revert();
	}
	_;}
	modifier onlyAuthorized(){
	if(msg.sender != crowdSaleAddress && msg.sender != owner){
	revert();
	}
	_;}
	constructor(address _crowdSaleAddress) public {
	locked = true;
	initialSupply = 10000000 * multiplier;
	totalSupply = initialSupply;
	name = "GXC";
	symbol = "GXC";
	decimals = 10;
	crowdSaleAddress = _crowdSaleAddress;
	balances[crowdSaleAddress] = totalSupply;
	}
	function restCrowdSaleAddress(address _newCrowdSaleAddress) onlyAuthorized public {
	crowdSaleAddress = _newCrowdSaleAddress;
	}
	function unlock() onlyAuthorized public {
	locked = false;
	}
	function lock() onlyAuthorized public {
	locked = true;
	}
	function burn(address _member, uint256 _value) onlyAuthorized public returns(bool ){
	balances[_member] = safeSub(balances[_member], _value);
	totalSupply = safeSub(totalSupply, _value);
	Transfer(_member, 0x0, _value);
	return true;
	}
	function transfer(address _to, uint _value) onlyUnlocked public returns(bool ){
	balances[msg.sender] = safeSub(balances[msg.sender], _value);
	balances[_to] = safeAdd(balances[_to], _value);
	Transfer(msg.sender, _to, _value);
	return true;
	}
	function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked public returns(bool success){
	if(balances[_from] < _value){
	revert();
	}
	if(_value > allowed[_from][msg.sender]){
	revert();
	}
	balances[_from] = safeSub(balances[_from], _value);
	balances[_to] = safeAdd(balances[_to], _value);
	allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
	Transfer(_from, _to, _value);
	return true;
	}
	function balanceOf(address _owner) view public returns(uint balance){
	return balances[_owner];
	}
	function approve(address _spender, uint _value) public returns(bool ){
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
	}
	function allowance(address _owner, address _spender) view public returns(uint remaining){
	return allowed[_owner][_spender];
	}
	
}