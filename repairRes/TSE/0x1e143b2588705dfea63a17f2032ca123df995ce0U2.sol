contract ClassicCheck {
	function isClassic() view public returns(bool isClassic);
}contract SafeConditionalHFTransfer {
	address contractOwner;
	bool classic;
	constructor(address param0, address _owner) public {
	classic = ClassicCheck(param0).isClassic();
	contractOwner = _owner;
	}
	function classicTransfer(address to) public {
	if(! classic){
	msg.sender.transfer(msg.value);
	}
	else{
	to.transfer(msg.value);
	}
	}
	function transfer(address to) public {
	if(classic){
	msg.sender.transfer(msg.value);
	}
	else{
	to.transfer(msg.value);
	}
	}
	function suicideFunc() public {
	require(contractOwner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}