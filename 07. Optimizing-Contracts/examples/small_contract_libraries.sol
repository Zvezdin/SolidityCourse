pragma solidity 0.4.20;

library Adder {
    function add(uint n, uint m) public pure returns (uint){
        return n+m;
    }
}

contract B {
    uint a;
    uint b;
    
    //42484 execution cost
    function doStuff() public returns(uint) {
        a = 3;
        b = 2;
        
        return Adder.add(a, b);
    }
    
    //10650 execution cost
    function doEfficientStuff() public returns (uint) {
        a = 3;
        b = 2;
        
        return a + b;
    }
}
