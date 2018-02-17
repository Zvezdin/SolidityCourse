pragma solidity ^0.4.19;

contract C {
    function f(uint len) public pure {
        uint[] memory a = new uint[](7);
        bytes memory b = new bytes(len);
        // Here we have a.length == 7 and b.length == len
        a[6] = 8;
        a.push(6); //doesn't work
        a.length += 2; //nope
    }
}