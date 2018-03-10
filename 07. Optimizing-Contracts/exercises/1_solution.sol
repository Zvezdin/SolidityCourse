pragma solidity 0.4.20;

contract Members {
    struct Member {
        address adr;
        uint joinedAt; //timestamp
    }
    
    address owner;
    bool initialized;
    
    mapping(address => Member) public members;
    
    function Members() public {
        owner = msg.sender;
    }
    
    function init(address[] addresses) public {
        require(owner == msg.sender);
        require(!initialized);
        
        for(uint i = 0; i < addresses.length; i++){
            members[addresses[i]] = Member({adr: addresses[i], joinedAt: now});
        }
        
        initialized = true;
    }
}
