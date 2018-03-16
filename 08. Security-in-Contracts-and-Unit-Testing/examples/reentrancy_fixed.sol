pragma solidity 0.4.21;

contract HoneyPot {
    mapping(address => uint) public balances;
    
    mapping(address => bool) public approvedMembers;
    
    function HoneyPot(address[] members) public {
        for(uint i=0; i<members.length; i++){
            approvedMembers[members[i]] = true;
        }
    }
    
    function put() public payable {
        balances[msg.sender] += msg.value;
    }
    
    function get(uint value) public {
        //checks
        require(approvedMembers[msg.sender]);
        require(value <= balances[msg.sender]);
        
        //effects
        balances[msg.sender] -= value;
        
        //interactions
        require(msg.sender.call.value(value)());
    }
    
    function bal() public view returns (uint) {
        return address(this).balance;
    }
    
    function() public {
        require(false);
    }
}
