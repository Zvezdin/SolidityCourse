pragma solidity ^0.4.19;

contract Owned {
    address owner;
    
    function Owned() public {
        owner = msg.sender;
    }
}

contract Mortal is Owned {
    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }
}

contract Base is Mortal {
    function kill() public { /* do cleanup */ Mortal.kill(); }
}

contract Final is Base {
    //a call to Final.kill() will call Base.kill() which will finally call Mortal.kill()
}

