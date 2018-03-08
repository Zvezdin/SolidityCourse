pragma solidity 0.4.20;

contract MemoryCopy {
    uint[] public data;
    
    function MemoryCopy() public {
        data.push(3);
        data.push(4);
    }
    
    function doStuff() public {
        //copies data from storage to memory!
        uint[] memory _data = data;
        
        _data[0] += 10; //doesn't change our data in storage
    }
    
    function doReferenceStuff() public {
        //_data is a reference to data
        uint[] storage _data = data;
        
        _data[0] += 10; //changes data in storage
    }
}
