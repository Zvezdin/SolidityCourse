pragma solidity ^0.4.19;

library Set {
    struct Data { mapping(uint => bool) flags; }

    // The argument is a storage reference! Yey for low gas expenses !
    // If the function can be seen as a method of that object, you should call the object "self"
    function insert(Data storage self, uint value) public returns (bool) {
        if (self.flags[value])
            return false; // already there
        self.flags[value] = true;
        return true;
    }
    
    function remove(Data storage self, uint value) public returns (bool) {
        if(!self.flags[value])
            return false; // not there
        self.flags[value] = false;
        return true;
    }
    
    function contains(Data storage self, uint value) public view returns (bool) {
        return self.flags[value];
    }
}

contract C {
    Set.Data knownValues;
    
    function register(uint value) public {
        // The library functions can be called without a
        // specific instance of the library, since the
        // "instance" will be the current contract.
        require(Set.insert(knownValues, value));
    }
    
    function testLib() public {
        if(Set.contains(knownValues, 42)){
            Set.remove(knownValues, 42);
        }
        
        assert(Set.insert(knownValues, 42));
        assert(Set.contains(knownValues, 42));
        assert(Set.remove(knownValues, 42));
        assert(!Set.contains(knownValues, 42));
    }
    // In this contract, we can also directly access knownValues.flags, if we want.
}
