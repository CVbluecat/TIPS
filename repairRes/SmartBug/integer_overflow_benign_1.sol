pragma solidity ^0.4.19;
contract IntegerOverflowBenign1 {
	uint public count = 1;
	function run(uint256 input) public {
	require(count >= input);
	uint res = count - input;
	}
	
}