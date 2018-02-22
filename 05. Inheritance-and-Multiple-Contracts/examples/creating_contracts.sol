pragma solidity 0.4.19;

contract MathHelper{
    function add(uint a, uint b) pure public returns (uint){
        return a+b;
    }
}

contract MathUser{
    MathHelper public math;
    uint public lastRes;
    
    function MathUser() public {
        math = new MathHelper();
    }
    
    function work() public {
        uint n = 3;
        uint m = 4;
        
        lastRes = math.add(n, m);
    }
    
    function temporaryContract() public returns (MathHelper) {
        MathHelper mat = new MathHelper();
        
        lastRes = mat.add(7, 8);
        
        return mat;
    }
}
