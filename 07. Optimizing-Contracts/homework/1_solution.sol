pragma solidity 0.4.21;


//this contract is optimized, don't touch it.
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


library MemberLib {
    struct Member {
        address adr;
        uint joinedAt;
        uint fundsDonated;
    }
    
    function createStructure(address adr) internal view returns (Member) {
        return Member({adr: adr, joinedAt: now, fundsDonated: 0});
    }
    
    function donated(Member storage self, uint value) public {
        self.fundsDonated += value;
    }
}

contract Membered is Ownable{
    using MemberLib for MemberLib.Member;
    
    mapping(address => MemberLib.Member) members;
    
    modifier onlyMember {
        require(members[msg.sender].adr == msg.sender);
        _;
    }
    
    function addMember(address adr) public onlyOwner {
        MemberLib.Member memory member = MemberLib.createStructure(adr);
        
        members[adr] = member;
    }
    
    function donate() public onlyMember payable {
        require(msg.value > 0);
        
        members[msg.sender].donated(msg.value);
    }
}
