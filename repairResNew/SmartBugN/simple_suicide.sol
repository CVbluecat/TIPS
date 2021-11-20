pragma solidity ^0.4.0;
contract SimpleSuicide {
	function sudicideAnyone() public {
	selfdestruct(msg.sender);
	}
	
}