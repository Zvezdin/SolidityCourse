pragma solidity 0.4.21;


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


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

library VotingLib {
    using SafeMath for uint;

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
        require(!self.finished);
        require(self.exists);
        require(!self.voted[msg.sender]);
        
        self.voted[msg.sender] = true;
        
        if(voteFor){
            self.votedFor = self.votedFor.add(importance);
            
            if(self.votedFor >= self.targetVotes) {
                self.finished = true;
                self.successful = true;
            }
        } else {
            self.votedAgainst = self.votedAgainst.add(importance);
            
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
    using SafeMath for uint;
    
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
    
    mapping(address => uint) withdrawals;
    
    modifier onlyMember {
        require(members[msg.sender].importance > 0);
        _;
    }
    
    uint totalImportance;
    bool initialized;
    
    function init(address[] membersAdr, uint[] importance) public onlyOwner {
        require(membersAdr.length >= 3);
        require(membersAdr.length == importance.length);
        require(!initialized);
        initialized = true;
        
        uint totalImp = 0;
        
        for(uint i=0; i<membersAdr.length; i++){
            members[membersAdr[i]].adr = membersAdr[i];
            members[membersAdr[i]].importance = importance[i];
            totalImp = totalImp.add(importance[i]);
            
            require(importance[i] > 0);
        }
        require(totalImp >= 3);
        
        totalImportance = totalImp; //memory caching
    }
    
    function startVote(address targetAdr, uint value) public onlyOwner returns(bytes32 ID){
        require(targetAdr != address(0));
        require(value > 0);
        
        ID = keccak256(targetAdr, value, now);
        
        require(!votings[ID].exists);
        
        VotingLib.Voting memory voting = VotingLib.createVoting(targetAdr, value, totalImportance/2);
        
        votings[ID] = voting;
        
        emit VotingStarted(ID, targetAdr, value);
    }
    
    function castVote(bytes32 ID, bool voteFor) public onlyMember {
        VotingLib.Voting storage voting = votings[ID];
        
        if(VotingLib.voteAndHasFinished(voting, voteFor, members[msg.sender].importance)){
            emit VotingEnded(ID, voting.successful);
            
            if(voting.successful) {
                withdrawals[voting.targetAdr] = withdrawals[voting.targetAdr].add(voting.value);
            }
        }
        
        emit Voted(ID, msg.sender, voteFor);
    }
    
    function withdraw() public {
        uint val = withdrawals[msg.sender];
        withdrawals[msg.sender] = 0;
        
        msg.sender.transfer(val);
    }
}
