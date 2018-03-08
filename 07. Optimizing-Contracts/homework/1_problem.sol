pragma solidity 0.4.20;

pragma solidity ^0.4.18;


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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

//The objective is to have a contract that has members. The members are added by the owner and hold information about their address, timestamp of being added to the contract and amount of funds donated. Each member can donate to the contract.
//Many anti-patterns have been used to create them.
//Some logical checks have been missed in the implementation.
//Objective: lower the publish/execution gas costs as much as you can and fix the logical checks.

contract MemberContr {
    struct Member {
        address adr;
        uint joinedAt;
        uint fundsDonated;
    }
    
    Member member;
    
    function MemberContr(address adr) public {
        member.adr = adr;
        member.joinedAt = now;
        member.fundsDonated = 0;
    }
    
    function donated(uint value) public {
        member.fundsDonated += value;
    }
    
    function get() public view returns (address, uint, uint) {
        return (member.adr, member.joinedAt, member.fundsDonated);
    }
}

contract Membered is Ownable{
    mapping(address => MemberContr) members;
    address[] memberList;
    
    address tmp1;
    uint tmp2;
    uint tmp3;
    
    modifier onlyMember {
        (tmp1, tmp2, tmp3) = members[msg.sender].get();
        require(tmp1 == msg.sender);
        _;
    }
    
    function addMember(address adr) public onlyOwner {
        MemberContr newMember = new MemberContr(adr);
        
        members[adr] = newMember;
        memberList.push(adr);
    }
    
    function donate() public onlyMember payable {
        require(msg.value > 0);
        
        members[msg.sender].donated(msg.value);
    }
}
