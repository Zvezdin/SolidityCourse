pragma solidity 0.4.20;

contract MemoryCache {
    uint a = 3;
    
    //53120 gas
    function doStuff() public {
        for(uint i = 0; i<10; i++){
            a++;
        }
    }
    
    //this method uses memory caching
    //do most changes on local variables and
    //write to storage at the end
    
    //6145 gas
    function doOptimalStuff() public {
        uint _a = a;
        for(uint i = 0; i<10; i++){
            _a++;
        }
        
        a = _a;
    }
}
