pragma solidity 0.4.20;


library VotingLib {
    struct Vote {
        uint ID;
        uint votesFor;
        uint votesAgainst;
        uint target;
        bool finished;
        bool successful;
        mapping(address => bool) voted;
    }
    
    //updates the vote count and checks for completion
    function update(Vote storage self, address voter, bool voteFor) public returns(bool){
        require(!self.finished);
        require(!self.voted[voter]);
        
        self.voted[voter] = true;
        
        if(voteFor){
            self.votesFor++;
        } else {
            self.votesAgainst++;
        }
        
        if(self.votesFor > self.target){
            self.finished = true;
            self.successful = true;
        } else if(self.votesAgainst >= self.target) {
            self.finished = true;
            self.successful = false;
        }
        
        return self.finished;
    }
}

contract Voting {
    using VotingLib for VotingLib.Vote;
    
    event LogStartedVote(uint ID);
    event LogEndedVote(uint ID, bool successful);
    
    mapping(uint => VotingLib.Vote) public votes;
    
    mapping(address => bool) isVoter;
    uint voters;
    
    bool initialized;
    address owner;
    
    modifier onlyVoter {
        require(isVoter[msg.sender]);
        _;
    }
    
    modifier isInit {
        require(initialized);
        _;
    }
    
    modifier voteExists(uint voteID) {
        require(votes[voteID].ID != 0);
        _;
    }
    
    function Voting() public {
        owner = msg.sender;
    }
    
    function initialize(address[] _voters) public {
        require(owner == msg.sender);
        require(_voters.length >= 2);
        require(!initialized);
        initialized = true;
        
        voters = _voters.length;
        
        for(uint i = 0; i<_voters.length; i++){
            isVoter[_voters[i]] = true;
        }
    }
    
    function startVote() public isInit onlyVoter returns(uint){
        uint voteID = now; //let the ID be a timestamp
        
        votes[voteID] = VotingLib.Vote({ID: voteID, votesFor: 0, votesAgainst: 0, target: voters/2, finished: false, successful: false});
        
        LogStartedVote(voteID);
        
        return voteID;
    }
    
    function vote(uint id, bool voteFor) public isInit onlyVoter voteExists(id) {
        if(votes[id].update(msg.sender, voteFor)){
            LogEndedVote(id, votes[id].successful);
        }
    }
}

