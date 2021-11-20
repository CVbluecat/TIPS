pragma solidity >=0.4.11;
contract Owned {
	constructor() public {
	owner = msg.sender;
	}
	address public owner;
	modifier onlyOwner(){
	if(msg.sender == owner){
	_;}
	}
	function changeOwner(address _newOwner) onlyOwner public {
	owner = _newOwner;
	}
	function execute(address _dst, uint _value, bytes _data) onlyOwner public {
	_dst.transfer(_value);
	}
	
}contract Token {
	function transfer(address , uint ) public returns(bool );function balanceOf(address ) view public returns(uint );
}contract TokenSender is Owned {
	Token public token;
	uint public totalToDistribute;
	uint public next;
	struct Transfer{
	address addr;
	uint amount;
	}
	Transfer[] public transfers;
	constructor(address _token) public {
	token = Token(_token);
	}
	uint constant D160 = 0x0010000000000000000000000000000000000000000;
	function fill(uint[] data) onlyOwner public {
	if(next > 0){
	throw;}
	uint acc;
	uint offset = transfers.length;
	transfers.length = transfers.length + data.length;
	for(uint i = 0;i < data.length;i++){
	address addr = address(data[i] & (D160 - 1));
	uint amount = data[i] / D160;
	transfers[offset + i].addr = addr;
	transfers[offset + i].amount = amount;
	acc += amount;
	}
	totalToDistribute += acc;
	}
	function run() onlyOwner public {
	if(transfers.length == 0){
	return ;
	}
	uint mNext = next;
	next = transfers.length;
	if((mNext == 0) && (token.balanceOf(this) != totalToDistribute)){
	throw;}
	while((mNext < transfers.length) && (gas() > 150000)){
	uint amount = transfers[mNext].amount;
	address addr = transfers[mNext].addr;
	if(amount > 0){
	if(! token.transfer(addr, transfers[mNext].amount)){
	throw;}
	}
	mNext++;
	}
	next = mNext;
	}
	function hasTerminated() view public returns(bool ){
	if(transfers.length == 0){
	return false;
	}
	if(next < transfers.length){
	return false;
	}
	return true;
	}
	function nTransfers() view public returns(uint ){
	return transfers.length;
	}
	function gas() view internal returns(uint _gas){
	assembly{
    _gas := gas()
}}
	
}