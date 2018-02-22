pragma solidity 0.4.20;

contract Crowdsale{
    mapping(address => uint) balances;
    
    mapping(address => bool) hadBalance;
    
    address[] public tokenOwners;
    
    uint start = now;
    address owner;
    
    modifier OnlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier CrowdSalePeriod{
        require(now < start + 5 minutes);
        _;
    }
    
    modifier WithdrawAllowed{
        require(now > start + 1 years);
        _;
    }
    
    function Crowdsale() public {
        owner = msg.sender;
    }
    
    function buy() CrowdSalePeriod public payable {
        require(msg.value / 1 ether > 0); //at least 1 ether
        require((msg.value / 1 ether) * 1 ether == msg.value); //accept only round ETH
        
        uint tokens = (msg.value / 1 ether) * 5 ;
        
        //the default balance for everybody is 0
        balances[msg.sender] += tokens;
        
        updateTokenOwners();
    }
    
    
    function updateTokenOwners() internal {
        if(!hadBalance[msg.sender]){
            tokenOwners.push(msg.sender);
            hadBalance[msg.sender] = true;
        }
    }
    
    function withdraw() public OnlyOwner WithdrawAllowed {
        owner.transfer(this.balance);
    }
    
    function transfer(uint tokens, address to) public {
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        
        updateTokenOwners();
    }
    
    function getTokenOwners() public view returns(address[]){
        return tokenOwners;
    }
}
