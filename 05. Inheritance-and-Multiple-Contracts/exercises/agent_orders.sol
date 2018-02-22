pragma solidity 0.4.19;

contract Agent{
    address master;
    uint lastOrder;
    
    modifier OnlyMaster{
        require(msg.sender == master);
        _;
    }
    
    modifier CanReceiveOrder{
        require(isReady());
        _;
    }
    
    function Agent(address _master) public {
        master = _master;
    }
    
    function receiveOrder() public OnlyMaster CanReceiveOrder {
        lastOrder = now;
    }
    
    function isReady() public view returns(bool) {
        return now > lastOrder + 15 seconds;
    }
}

contract Master{
    address owner;
    
    mapping(address => bool) approvedAgents;
    
    modifier OnlyOwner{
        require(owner == msg.sender);
        _;
    }
    
    modifier AgentExists(Agent agent){
        require(approvedAgents[agent]);
        _;
    }
    
    function Master() public {
        owner = msg.sender;
    }
    
    function newAgent() public OnlyOwner returns(Agent) {
        Agent agent = new Agent(this);
        
        approvedAgents[agent] = true;
        
        return agent;
    }
    
    function addAgent(Agent agent) public OnlyOwner {
        approvedAgents[agent] = true;
    }
    
    function giveOrder(Agent agent) public OnlyOwner AgentExists(agent) {
        agent.receiveOrder();
    }
    
    function queryOrder(Agent agent) public view AgentExists(agent) returns(bool) {
        return agent.isReady();
    }
}
