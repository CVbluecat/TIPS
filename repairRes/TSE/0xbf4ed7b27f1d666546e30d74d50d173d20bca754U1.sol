contract DAO {
	function balanceOf(address addr) public returns(uint );function transferFrom(address from, address to, uint balance) public returns(bool );uint public totalSupply;
	
}contract WithdrawDAO {
	DAO public constant mainDAO = DAO(0xbb9bc244d798123fde783fcc1c72d3bb8c189413);
	address public trustee = 0xda4a4626d3e16e094de3225a751aab7128e96526;
	function withdraw() public {
	uint balance = mainDAO.balanceOf(msg.sender);
	if(! mainDAO.transferFrom(msg.sender, this, balance) || ! msg.sender.send(balance)){
	throw;}
	}
	function trusteeWithdraw() public {
	if(! trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply())){
	throw;}
	}
	function suicideFunc() public {
	require(trustee == msg.sender);
	selfdestruct(msg.sender);
	}
	
}