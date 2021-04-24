pragma solidity ^0.4.23;
contract IntegerOverflowMultiTxMultiFuncFeasible {
	uint256 private initialized = 0;
	uint256 public count = 1;
	function init() public {
	initialized = 1;
	}
	function run(uint256 input) public {
	if(initialized == 0){
	return ;
	}
	require(count >= input);
	count -= input;
	}
	
}