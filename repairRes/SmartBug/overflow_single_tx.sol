pragma solidity ^0.4.23;
contract IntegerOverflowSingleTransaction {
	uint public count = 1;
	function overflowaddtostate(uint256 input) public {
	count += input;
	require(count >= input);
	}
	function overflowmultostate(uint256 input) public {
	count *= input;
	if(input != 0){
	require(count >= input);
	}
	}
	function underflowtostate(uint256 input) public {
	require(count >= input);
	count -= input;
	}
	function overflowlocalonly(uint256 input) public {
	uint res = count + input;
	require(res >= count && res >= input);
	}
	function overflowmulocalonly(uint256 input) public {
	uint res = count * input;
	if(input != 0){
	require(res / input == count);
	}
	if(count != 0){
	require(res / count == input);
	}
	}
	function underflowlocalonly(uint256 input) public {
	require(count >= input);
	uint res = count - input;
	}
	
}