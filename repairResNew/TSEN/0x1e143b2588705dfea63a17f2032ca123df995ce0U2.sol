contract ClassicCheck {
	function isClassic() view public returns(bool isClassic);
}contract SafeConditionalHFTransfer {
	bool classic;
	constructor() public {
	classic = ClassicCheck(0x882fb4240f9a11e197923d0507de9a983ed69239).isClassic();
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
	
}