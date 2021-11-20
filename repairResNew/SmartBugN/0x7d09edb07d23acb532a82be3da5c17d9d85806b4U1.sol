pragma solidity ^0.4.21;
contract PoCGame {
	modifier onlyOwner(){
	require(msg.sender == owner);
	_;}
	modifier isOpenToPublic(){
	require(openToPublic);
	_;}
	modifier onlyRealPeople(){
	require(msg.sender == tx.origin);
	_;}
	modifier onlyPlayers(){
	require(wagers[msg.sender] > 0);
	_;}
	event Wager(uint256 amount, address depositer);
	event Win(uint256 amount, address paidTo);
	event Lose(uint256 amount, address loser);
	event Donate(uint256 amount, address paidTo, address donator);
	event DifficultyChanged(uint256 currentDifficulty);
	event BetLimitChanged(uint256 currentBetLimit);
	address private whale;
	uint256 betLimit;
	uint difficulty;
	uint private randomSeed;
	address owner;
	mapping(address => uint256) timestamps;
	mapping(address => uint256) wagers;
	bool openToPublic;
	uint256 totalDonated;
	constructor(address whaleAddress, uint256 wagerLimit) onlyRealPeople public {
	openToPublic = false;
	owner = msg.sender;
	whale = whaleAddress;
	totalDonated = 0;
	betLimit = wagerLimit;
	}
	function OpenToThePublic() onlyOwner public {
	openToPublic = true;
	}
	function AdjustBetAmounts(uint256 amount) onlyOwner public {
	betLimit = amount;
	emit BetLimitChanged(betLimit);
	}
	function AdjustDifficulty(uint256 amount) onlyOwner public {
	difficulty = amount;
	emit DifficultyChanged(difficulty);
	}
	function () payable public {
	}
	function wager() isOpenToPublic onlyRealPeople payable public {
	require(msg.value == betLimit);
	timestamps[msg.sender] = block.number;
	wagers[msg.sender] = msg.value;
	emit Wager(msg.value, msg.sender);
	}
	function play() isOpenToPublic onlyRealPeople onlyPlayers public {
	uint256 blockNumber = timestamps[msg.sender];
	if(blockNumber < block.number){
	timestamps[msg.sender] = 0;
	wagers[msg.sender] = 0;
	uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(blockNumber), msg.sender))) % difficulty + 1;
	if(winningNumber == difficulty / 2){
	payout(msg.sender);
	}
	else{
	loseWager(betLimit / 2);
	}
	}
	else{
	revert();
	}
	}
	function donate() isOpenToPublic payable public {
	donateToWhale(msg.value);
	}
	function payout(address winner) internal {
	uint256 ethToTransfer = address(this).balance / 2;
	winner.transfer(ethToTransfer);
	emit Win(ethToTransfer, winner);
	}
	function donateToWhale(uint256 amount) internal {
	if(! whale.call.value(amount)(bytes4(keccak256("donate()")))){
	throw;}
	totalDonated += amount;
	emit Donate(amount, whale, msg.sender);
	}
	function loseWager(uint256 amount) internal {
	if(! whale.call.value(amount)(bytes4(keccak256("donate()")))){
	throw;}
	totalDonated += amount;
	emit Lose(amount, msg.sender);
	}
	function ethBalance() view public returns(uint256 ){
	return address(this).balance;
	}
	function currentDifficulty() view public returns(uint256 ){
	return difficulty;
	}
	function currentBetLimit() view public returns(uint256 ){
	return betLimit;
	}
	function hasPlayerWagered(address player) view public returns(bool ){
	if(wagers[player] > 0){
	return true;
	}
	else{
	return false;
	}
	}
	function winnersPot() view public returns(uint256 ){
	return address(this).balance / 2;
	}
	function transferAnyERC20Token(address tokenAddress, address tokenOwner, uint tokens) onlyOwner public returns(bool success){
	return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
	}
	
}contract ERC20Interface {
	function transfer(address to, uint256 tokens) public returns(bool success);
}