pragma solidity 0.4.20;

contract A {
    struct FourInts {
        uint a;
        uint b;
        uint c;
        uint d;
    }
    
    function doStuff() public {
        //WARNING! Don't remove the "memory":
        //FourInts ints; - this is an unitialized storage pointer
        //if you want to declare a local struct variable
        //make it in memory
        FourInts memory ints;
        ints.a = 1;
        ints.b = 2;
        ints.c = 3;
        ints.d = 4;
    }
    
    function doOptimalStuff() public {
        FourInts memory ints = FourInts({a: 1, b: 2, c: 3, d: 4});
    }
}
