pragma solidity 0.4.20;

contract Ownable {
    address public owner;
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Counter is Ownable {
    uint times = 0;
    uint value = 0;
    
    function count(uint incrementBy) public onlyOwner returns (uint, uint){
        value += incrementBy;
        times ++;
        
        return (times, value);
    }
    
    function getCounter() public view returns (uint, uint) {
        return (times, value);
    }
}

