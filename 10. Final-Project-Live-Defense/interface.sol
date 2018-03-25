pragma solidity 0.4.19;

contract DDNS {
    struct Receipt{
        uint amountPaidWei;
        uint timestamp;
        uint expires;
    }
    
    //This will create an automatic getter with 2 arguments: address and index of receipt
    mapping(address => Receipt[]) public receipts;

    //the domain is bytes, because string is UTF-8 encoded and we cannot get its length
    //the IP is bytes4 because it is more efficient in storing the sequence
    function register(bytes domain, bytes4 ip) public payable {}
    
    function edit(bytes domain, bytes4 newIp) public {}
    
    function transferDomain(bytes domain, address newOwner) public {}
    
    function getIP(bytes domain) public view returns (bytes4) {}
    
    function getPrice(bytes domain) public view returns (uint) {}

    //function for the optional requirement for a withdraw function. Implement if you want.
    function withdraw() public {}
}

contract Marketplace {
    function buy(bytes32 ID, uint quantity) public payable {}
    
    function update(bytes32 ID, uint newQuantity) public {}
    
    //creates a new product and returns its ID
    function newProduct(string name, uint price, uint quantity) public returns(bytes32) {}
    
    function getProduct(bytes32 ID) public view returns(string name, uint price, uint quantity) {}
    
    function getProducts() public view returns(bytes32[]) {}
    
    function getPrice(bytes32 ID, uint quantity) public view returns (uint) {}

    //function for the optional requirement for a withdraw function. Implement if you want.
    function withdraw() public {}
}


