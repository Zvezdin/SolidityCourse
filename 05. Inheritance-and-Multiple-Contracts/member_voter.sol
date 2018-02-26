pragma solidity ^0.4.19;


//provides basic authorization control functions
contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Destructible is Ownable {
    
    function Destructible() public payable { }

    function destroy() onlyOwner public {
        selfdestruct(owner);
    }
    
    function destroyAndSend(address _recipient) onlyOwner public {
        selfdestruct(_recipient);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        //there is no case where this function can overflow/underflow
        uint256 c = a / b;
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

library MemberLib {
    using SafeMath for uint;
    
    struct Member {
        address adr; //an adr value of 0 means that the person is not a member
        uint totalValue; //in wei
        uint lastDonation; //timestamp
        uint lastValue; //in wei
    }
    
    function memberHasTimedOut(Member storage self) public view returns (bool) {
        if(self.lastDonation + 1 hours < now) { //the member didn't donate and must be removed
            return true;
        }
        
        return false;
    }
    
    function remove(Member storage self) public {
        self.adr = 0;
    }
    
    function initialize(Member storage self, address adr) public {
        self.adr = adr;
        self.lastDonation = now; //give the new member time to donate so he isn't kicked right away
    }
    
    function update(Member storage self, uint donatedValue) public {
        self.lastValue = donatedValue;
        self.lastDonation = now;
        self.totalValue = self.totalValue.add(donatedValue);
    }
}

contract MemberVoter is Ownable, Destructible {
    using SafeMath for uint; //all integer operations are using the safe library
    using MemberLib for MemberLib.Member;
    
    //define our contract events
    event LogMemberAdded(address indexed adr);
    event LogMemberRemoved(address indexed adr);
    event LogVotingStarted(bytes32 indexed id);
    event LogVotingEnded(bytes32 indexed id, bool successful);
    event LogDonation(address indexed from, uint value);
    
    mapping(address => MemberLib.Member) public members;
    
    //we should increase or decrease this counter as members are added and removed
    uint memberCount;
    
    struct Voting {
        address proposedMember;
        uint votesFor;
        uint votesAgainst;
        mapping(address =>  bool) voted;
    }
    
    mapping(bytes32 => Voting) public votings; //the key is the hash of the proposed member and the current timestamp
    
    //we should increase or decrease this counter as votings are added and removed
    //IMPORTANT! No member can be removed when there are active votings.
    uint activeVotings;
    
    modifier canRemoveMember(address adr) {
        require(adr != owner); //the owner cannot be removed
        require(activeVotings == 0); //no member can be removed during votings
        _;
    }
    
    modifier canAddMember(address adr) {
        require(adr != 0); //the address should exist
        _;
    }
    
    modifier onlyMember {
        //the caller must be a member
        require(members[msg.sender].adr != 0);
        
        //try to check if the member should be removed. If not, execute the function.
        if(!tryRemovingMember(msg.sender)) {
            _;
        }
    }
    
    modifier hasValue {
        require(msg.value > 0);
        _;
    }
    
    function MemberVoter() public {
        memberCount = 0;
        _addMember(owner); //initialize the owner as the first member
    }
    
    function _addMember(address adr) private canAddMember(adr) {
        members[adr].initialize(adr);
        memberCount = memberCount.add(1);
        
        LogMemberAdded(adr);
    }
    
    function _removeMember(address adr) private canRemoveMember(adr) { //private method that removes a member
        members[adr].remove();
        memberCount = memberCount.sub(1); //this should never overflow
        
        LogMemberRemoved(adr);
    }
    
    function removeMember(address adr) public onlyOwner { //owner-only interface to the private method
        _removeMember(adr);
    }
    
    //if a member should be removed but isn't yet and this is disrupting a voting,
    //anyone can try 'poking' the contract so that it checks if a given member should be removed
    //returns true if the member was removed
    function tryRemovingMember(address adr) public returns (bool) {
        if(members[adr].memberHasTimedOut()) { //the member didn't donate and must be removed
            if(activeVotings == 0){ //the contract is locked if there are votings. Nobody can be removed during that time.
                _removeMember(adr);
                return true;
            }
        }
        
        return false;
    }
    
    function donate() public payable onlyMember hasValue {
        //update our member's data
        members[msg.sender].update(msg.value);
        
        LogDonation(msg.sender, msg.value);
    }
    
    function _addVoting(address proposedMember) private canAddMember(proposedMember) returns (bytes32) {
        bytes32 id = keccak256(proposedMember, now); //the ID of a vote is the unique hash of the member and the current time 
        
        votings[id] = Voting({proposedMember: proposedMember, votesFor: 0, votesAgainst: 0});
        activeVotings = activeVotings.add(1);
        
        LogVotingStarted(id);
        
        return id;
    }
    
    function _removeVoting(bytes32 id) private {
        votings[id].proposedMember = 0;
        activeVotings = activeVotings.sub(1);
    }
    
    //propose a new member. Returns the ID of the started voting
    function proposeMember(address proposedMember) public onlyMember returns (bytes32) {
        require(!members[msg.sender].memberHasTimedOut()); //the modifier onlyMember may allow access to a timed out member if votings are active
        //make sure that a timed out member cannot start another voting (and keep being a member indefinitely)
        
        _addVoting(proposedMember);
    }
    
    function vote(bytes32 id, bool voteFor) public onlyMember {
        require(votings[id].proposedMember != 0); //the voting should exist
        require(!votings[id].voted[msg.sender]);
        
        votings[id].voted[msg.sender] = true;
        
        if(voteFor){ //update the votes count
            votings[id].votesFor = votings[id].votesFor.add(1);
        } else {
            votings[id].votesAgainst = votings[id].votesAgainst.add(1);
        }
        
        if(votings[id].votesFor > memberCount.div(2)){ //if the vote is successful
            _addMember(votings[id].proposedMember);
            _removeVoting(id);
            
            LogVotingEnded(id, true);
        } else if(votings[id].votesAgainst > memberCount.div(2)) { //unsuccessful vote
            _removeVoting(id);
            
            LogVotingEnded(id, false);
        }
    }
}
