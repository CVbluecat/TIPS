pragma solidity ^0.4.24;
contract Missing{
    address private owner;
    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    function XIXI() public{
        owner = msg.sender;
    }
}