pragma solidity 0.4.19;

contract ArrayTest{
    uint[3] public threeInts = [1,2,3];
    //automatic index getter
    
    uint[] public manyInts;
    
    function increment(uint8 index) public {
        threeInts[index] += 1;
    }
    
    function push(uint newInt) public {
        manyInts.push(newInt);
        //same as:
        manyInts.length += 1;
        manyInts[manyInts.length-1] = newInt;
    }
    
    //warning: only works if called from the outside, not a contract
    function getManyInts() public view returns(uint[]){
        return manyInts;
    }
    
    function getThreeInts() public view returns (uint[3]){
        return threeInts;
    }
}