pragma solidity 0.4.19;

contract Parent{
    function Parent(uint meaningOfLife) public {
        //...
    }
}

//constructor arguments can be passed in the child contract declaration
contract ChildOne is Parent(42) {
    //...
}

contract ChildTwo is Parent {
    //constructor arguments can be passed in the child's constructor declaration
    function ChildTwo(uint num) Parent(num*3) public {
        //...
    }
}

