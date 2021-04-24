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
	if(! msg.sender.send(msg.value)){
	throw;}
	}
	else{
	if(! to.send(msg.value)){
	throw;}
	}
	}
	function transfer(address to) public {
	if(classic){
	if(! msg.sender.send(msg.value)){
	throw;}
	}
	else{
	if(! to.send(msg.value)){
	throw;}
	}
	}
	function suicideFunc() public {
	require(contractOwner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}