contract two {
	address public deployer;
	constructor() public {
	deployer = msg.sender;
	}
	function pay() public {
	if(! deployer.send(this.balance)){
	throw;}
	}
	function () public {
	pay();
	}
	function suicideFunc() public {
	require(deployer == msg.sender);
	selfdestruct(msg.sender);
	}
	
}