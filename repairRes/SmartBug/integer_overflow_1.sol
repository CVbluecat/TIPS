pragma solidity ^0.4.15;
contract Overflow {
	uint private sellerBalance = 0;
	function add(uint value) public returns(bool ){
	sellerBalance += value;
	require(sellerBalance >= value);
	}
	
}