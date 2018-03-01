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

contract Adder is Ownable {
    event LogSetState(uint state);
    event LogAdding(uint result, uint paidWei);
    
    uint a;
    
    function Util(uint _a) public {
        setA(_a);
    }
    
    function setA(uint _a) public onlyOwner {
        a = _a;
        LogSetState(a);
    }
    
    function getA() public view returns (uint){
        return a;
    }
    
    function add(uint b) public payable returns (uint){
        require(msg.value > 1 ether);
        uint res = a+b;
        
        LogAdding(a, msg.value);
        
        return res;
    }
}
