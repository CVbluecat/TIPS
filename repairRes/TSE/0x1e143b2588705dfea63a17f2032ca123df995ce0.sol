contract ClassicCheck {
	function isClassic() view public returns(bool isClassic);
}contract SafeConditionalHFTransfer {
	address owner;
	bool classic;
	constructor(address param0) public {
	classic = ClassicCheck(param0).isClassic();
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
	require(owner == msg.sender);
	selfdestruct(msg.sender);
	}
	
}