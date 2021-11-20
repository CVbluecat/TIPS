contract ClassicCheck {
	function isClassic() view public returns(bool isClassic);
}contract SafeConditionalHFTransfer {
	bool classic;
	constructor() public {
	classic = ClassicCheck(0x882fb4240f9a11e197923d0507de9a983ed69239).isClassic();
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
	
}