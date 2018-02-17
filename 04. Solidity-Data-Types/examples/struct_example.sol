pragma solidity 0.4.19;

contract Funding {
    struct HighestBidder {
        address addr;
        uint amount;
    }
    
    HighestBidder public highestBidder;
    
    function Funding() public {
        //initialize with
        highestBidder = HighestBidder(msg.sender, 0);
        //or
        highestBidder = HighestBidder({addr: msg.sender, amount: 0});
        //or (more costly on the gas)
        highestBidder.addr = msg.sender;
        highestBidder.amount = 0;
    }
    
    function bid() public payable {
        if(msg.value > highestBidder.amount){ //new high bidder
            highestBidder = HighestBidder(msg.sender, msg.value);
        }
    }
}