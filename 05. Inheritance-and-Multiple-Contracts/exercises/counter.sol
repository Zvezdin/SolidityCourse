pragma solidity 0.4.19;

contract Owned{
    address owner;
    
    function Owned() public {
        owner = msg.sender;
    }
    
    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address to) public OnlyOwner{
        owner = to;
    }
}


contract SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Counter is Owned, SafeMath {
    uint256 state;
    uint256 lastChange = now;
    
    function changeState() public {
        state = add(state, now % 256);
        state = mul(state, sub(now, lastChange) );
        state = sub(state, block.gaslimit);
    }
}
