pragma solidity 0.4.20;

contract Distributor {
    address[] members;
    
    address owner;
    bool initialized; //false by default
    
    mapping(address => uint) public withdrawals;
    
    modifier isInitialized{
        require(initialized);
        _;
    }
    
    function Distributor() public {
        owner = msg.sender;
    }
    
    function init(address[] addresses) public {
        require(msg.sender == owner);
        require(!initialized);
        
        members = addresses;
        
        initialized = true;
    }
    
    function distribute() public isInitialized payable {
        require(msg.value > members.length);
        
        uint sendToEach = this.balance / members.length;
        
        for(uint i=0; i<members.length; i++){
            withdrawals[members[i]] += sendToEach;
        }
    }
    
    function withdraw() public {
        //WARNING! Important to first update our contract variables and THEN transfer the value!
        withdrawals[msg.sender] = 0;
        msg.sender.transfer(withdrawals[msg.sender]);
    }
}
