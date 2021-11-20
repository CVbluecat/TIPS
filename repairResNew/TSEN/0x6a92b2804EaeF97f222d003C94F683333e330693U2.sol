contract two {
	address public deployer;
	constructor() public {
	deployer = msg.sender;
	}
	function pay() public {
	deployer.transfer(this.balance);
	}
	function () public {
	pay();
	}
	
}