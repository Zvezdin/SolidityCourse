pragma solidity 0.4.20;

//define interface contract
//this is the same as the abstract example, but here we also have the limitations of the interface
interface Feline {
    function utterance() external returns (bytes32);
}

//implement the abstract method from parent
contract Cat is Feline {
    function utterance() external returns (bytes32) { return "miaow"; }
}
