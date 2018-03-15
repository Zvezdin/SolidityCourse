pragma solidity 0.4.21;

pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


library VotingLib {

    struct Voting {
        address targetAdr;
        uint value;
        mapping(address => bool) voted;
        uint votedFor;
        uint votedAgainst;
        uint targetVotes;
        bool exists;
        bool successful;
        bool finished;
    }
    
    function createVoting(address targetAdr, uint value, uint targetVotes) internal pure returns(Voting) {
        return Voting({targetAdr: targetAdr, value: value, votedFor: 0, votedAgainst: 0, targetVotes: targetVotes, exists: true, successful: false, finished: false});
    }
    
    function voteAndHasFinished(Voting storage self, bool voteFor, uint importance) internal returns(bool){

        if(voteFor){
            self.votedFor = self.votedFor + importance;
            
            if(self.votedFor >= self.targetVotes) {
                self.finished = true;
                self.successful = true;
            }
        } else {
            self.votedAgainst = self.votedAgainst + importance;
            
            if(self.votedAgainst > self.targetVotes) {
                self.finished = true;
                self.successful = false;
            }
        }
        
        return self.finished;
    }
}


contract MemberVoter is Ownable {
    using VotingLib for VotingLib.Voting;
    
    event VotingStarted(bytes32 indexed ID, address indexed targetAdr, uint value);
    event Voted(bytes32 indexed ID, address indexed adr, bool voteFor);
    event VotingEnded(bytes32 indexed ID, bool successful);
    event Withdrawal(address indexed from, uint value);
    
    mapping(bytes32 => VotingLib.Voting) votings;
    
    struct Member {
        address adr;
        uint importance;
    }
    
    mapping(address => Member) members;
    
    modifier onlyMember {
        require(members[msg.sender].importance > 0);
        _;
    }
    
    uint totalImportance;
    
    function init(address[] membersAdr, uint[] importance) public onlyOwner {
        
        uint totalImp = 0;
        
        for(uint i=0; i<membersAdr.length; i++){
            members[membersAdr[i]].adr = membersAdr[i];
            members[membersAdr[i]].importance = importance[i];
            totalImp += importance[i];
 
        }
        
        totalImportance = totalImp; //memory caching
    }
    
    function startVote(address targetAdr, uint value) public onlyOwner returns(bytes32 ID){
        ID = keccak256(targetAdr, value, now);
        
        VotingLib.Voting memory voting = VotingLib.createVoting(targetAdr, value, totalImportance/2);
        
        votings[ID] = voting;
        
        emit VotingStarted(ID, targetAdr, value);
    }
    
    function castVote(bytes32 ID, bool voteFor) public onlyMember {
        VotingLib.Voting storage voting = votings[ID];
        
        if(VotingLib.voteAndHasFinished(voting, voteFor, members[msg.sender].importance)){
            emit VotingEnded(ID, voting.successful);
            
            if(voting.successful) {
                voting.targetAdr.call.value(voting.value)();
            }
        }
        
        emit Voted(ID, msg.sender, voteFor);
    }
}
