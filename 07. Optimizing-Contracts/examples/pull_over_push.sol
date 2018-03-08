//Source of Example: https://consensys.github.io/smart-contract-best-practices/recommendations/#favor-pull-over-push-for-external-calls
pragma solidity 0.4.20;

// bad
contract Auction {
    address highestBidder;
    uint highestBid;

    function bid() public payable {
        require(msg.value >= highestBid);

        if (highestBidder != 0) {
            // if this call consistently fails, no one else can bid
            highestBidder.transfer(highestBid);
        }

       highestBidder = msg.sender;
       highestBid = msg.value;
    }
}

// good
contract betterAuction {
    address highestBidder;
    uint highestBid;
    mapping(address => uint) refunds;

    function bid() payable external {
        require(msg.value >= highestBid);

        if (highestBidder != 0) {
            // record the refund that this user can claim
            refunds[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdrawRefund() external {
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;
        msg.sender.transfer(refund);
    }
}
