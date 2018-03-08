pragma solidity 0.4.20;

contract A {
    uint[] data;
    
    address owner;
    
    function A(uint[] _data) public {
        owner = msg.sender;
        
        data = _data; //heavy operation
    }
}

//Contract with more efficient initialization
//But requres two transactions - one to upload it, the other to call init()
//init() is best to be used when your constructor is large enough and the contract can't be published
contract B {
    uint[] data;
    
    bytes23 a;
    
    address owner;
    bool initialized;
    
    function B() public {
        owner = msg.sender;
    }
    
    function init(uint[] _data) public {
        require(owner == msg.sender);
        require(!initialized);
        
        data = _data;
        initialized = true;
    }
}
