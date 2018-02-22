pragma solidity 0.4.19;

contract Consensus {
    address[] public owners;
    
    function Consensus(address[] _owners) public {
        owners = _owners;
    }
    
    function getOwners() public view returns (address[]){
        return owners;
    }
}
