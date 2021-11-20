contract HonestDice {
	event Bet(address indexed user, uint blocknum, uint256 amount, uint chance);
	event Won(address indexed user, uint256 amount, uint chance);
	struct Roll{
	uint256 value;
	uint chance;
	uint blocknum;
	bytes32 secretHash;
	bytes32 serverSeed;
	}
	uint betsLocked;
	address owner;
	address feed;
	uint256 minimumBet = 1 * 1000000000000000000;
	uint256 constant maxPayout = 5;
	uint constant seedCost = 100000000000000000;
	mapping(address => Roll) rolls;
	uint constant timeout = 20;
	constructor() public {
	owner = msg.sender;
	feed = msg.sender;
	}
	function roll(uint chance, bytes32 secretHash) public {
	if(chance < 1 || chance > 255 || msg.value < minimumBet || calcWinnings(msg.value, chance) > getMaxPayout() || betsLocked != 0){
	if(! msg.sender.send(msg.value)){
	throw;}
	return ;
	}
	rolls[msg.sender] = Roll(msg.value, chance, block.number, secretHash, 0);
	Bet(msg.sender, block.number, msg.value, chance);
	}
	function serverSeed(address user, bytes32 seed) public {
	if(msg.sender != feed){
	return ;
	}
	if(rolls[user].serverSeed != 0){
	return ;
	}
	rolls[user].serverSeed = seed;
	}
	function hashTo256(bytes32 hash) public returns(uint _r){
	return uint(hash) & 0xff;
	}
	function hash(bytes32 input) public returns(uint _r){
	return uint(sha3(input));
	}
	function isReady() public returns(bool _r){
	return isReadyFor(msg.sender);
	}
	function isReadyFor(address _user) public returns(bool _r){
	Roll r = rolls[_user];
	if(r.serverSeed == 0){
	return false;
	}
	return true;
	}
	function getResult(bytes32 secret) public returns(uint _r){
	Roll r = rolls[msg.sender];
	if(r.serverSeed == 0){
	return ;
	}
	if(sha3(secret) != r.secretHash){
	return ;
	}
	return hashTo256(sha3(secret, r.serverSeed));
	}
	function didWin(bytes32 secret) public returns(bool _r){
	Roll r = rolls[msg.sender];
	if(r.serverSeed == 0){
	return ;
	}
	if(sha3(secret) != r.secretHash){
	return ;
	}
	if(hashTo256(sha3(secret, r.serverSeed)) < r.chance){
	return true;
	}
	return false;
	}
	function calcWinnings(uint256 value, uint chance) public returns(uint256 _r){
	return (value * 99 / 100) * 256 / chance;
	}
	function getMaxPayout() public returns(uint256 _r){
	return this.balance * maxPayout / 100;
	}
	function claim(bytes32 secret) public {
	Roll r = rolls[msg.sender];
	if(r.serverSeed == 0){
	return ;
	}
	if(sha3(secret) != r.secretHash){
	return ;
	}
	if(hashTo256(sha3(secret, r.serverSeed)) < r.chance){
	if(! msg.sender.send(calcWinnings(r.value, r.chance) - seedCost)){
	throw;}
	Won(msg.sender, r.value, r.chance);
	}
	delete rolls[msg.sender];
	}
	function canClaimTimeout() public returns(bool _r){
	Roll r = rolls[msg.sender];
	if(r.serverSeed != 0){
	return false;
	}
	if(r.value <= 0){
	return false;
	}
	if(block.number < r.blocknum + timeout){
	return false;
	}
	return true;
	}
	function claimTimeout() public {
	if(! canClaimTimeout()){
	return ;
	}
	Roll r = rolls[msg.sender];
	if(! msg.sender.send(r.value)){
	throw;}
	delete rolls[msg.sender];
	}
	function getMinimumBet() public returns(uint _r){
	return minimumBet;
	}
	function getBankroll() public returns(uint256 _r){
	return this.balance;
	}
	function getBetsLocked() public returns(uint _r){
	return betsLocked;
	}
	function setFeed(address newFeed) public {
	if(msg.sender != owner){
	return ;
	}
	feed = newFeed;
	}
	function lockBetsForWithdraw() public {
	if(msg.sender != owner){
	return ;
	}
	uint betsLocked = block.number;
	}
	function unlockBets() public {
	if(msg.sender != owner){
	return ;
	}
	uint betsLocked = 0;
	}
	function withdraw(uint amount) public {
	if(msg.sender != owner){
	return ;
	}
	if(betsLocked == 0 || block.number < betsLocked + 5760){
	return ;
	}
	if(! owner.send(amount)){
	throw;}
	}
	
}