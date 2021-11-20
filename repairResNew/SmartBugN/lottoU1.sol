pragma solidity ^0.4.18;
contract Lotto {
	bool public payedOut = false;
	address public winner;
	uint public winAmount;
	function sendToWinner() public {
	require(! payedOut);
	if(! winner.send(winAmount)){
	throw;}
	payedOut = true;
	}
	function withdrawLeftOver() public {
	require(payedOut);
	if(! msg.sender.send(this.balance)){
	throw;}
	}
	
}