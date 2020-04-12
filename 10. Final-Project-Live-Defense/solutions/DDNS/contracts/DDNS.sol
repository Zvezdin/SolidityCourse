pragma solidity 0.4.21;

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

contract DDNS is Ownable {
    struct Receipt{
        uint amountPaidWei;
        uint timestamp;
        uint expires;
    }
    
    struct Domain {
        address owner;
        uint expires;
        bytes4 ip;
        bool exists;
    }
    
    event LogDomainRegistered(address indexed by, bytes domain, uint expires, uint paid);
    event LogDomainRedirected(bytes domain, bytes4 newIp);
    event LogOwnershipTransferred(address indexed by, address indexed to, bytes domain);
    
    
    mapping(bytes32 => Domain) domains;
    mapping(address => Receipt[]) public receipts;
    
    modifier canRegisterDomain(bytes domain) {
        require(domain.length >= 5);
        
        Domain storage domainObj = _getDomain(domain);
        if(domainObj.exists && msg.sender != domainObj.owner){
            require(now >= domainObj.expires); //if expired
        }
        _;
    }
    
    modifier onlyDomainOwner(bytes domain) {
        require(_getDomain(domain).owner == msg.sender);
        _;
    }
    
    modifier domainNotExpired(bytes domain) {
        require(_getDomain(domain).expires > now);
        _;
    }
    
    modifier domainLongEnough(bytes domain) {
        require(domain.length > minDomainLength);
        _;
    }
    
    modifier addressValid(address adr) {
        require(adr != 0x0);
        _;
    }
    
    uint8 constant minDomainLength = 5;
    uint constant domainRegistrationPeriod = 1 years;
    uint constant domainBasePrice = 1 ether;
    
    function _getDomain(bytes domain) internal view returns(Domain storage){
        return domains[keccak256(domain)];
    }
    
    function register(bytes domain, bytes4 ip) public canRegisterDomain(domain) domainLongEnough(domain) payable {
        uint price = getPrice(domain);
        require(msg.value >= price);
        
        Domain storage domainObj = _getDomain(domain);
        
        //if the domain hasn't yet expired, lengthen it from the future expiration date.
        //otherwise count 1 year from now on
        uint newExpiration = domainObj.expires > now ? domainObj.expires + domainRegistrationPeriod : now + domainRegistrationPeriod;
        
        //we can't update the domain the following more efficient way:
        //    domainObj = Domain({owner: msg.sender, expires: newExpiration, ip: ip, exists: true});
        //because the variable domainObj is a storage pointer, not a storage location
        //for example, the following will work:
        //    domains[keccak256(domain)] = Domain({owner: msg.sender, expires: newExpiration, ip: ip, exists: true});
        //but we have a function to access a domain object by domain bytes and it is best to use that instead of
        //managing our domain mapping
        
        domainObj.expires = newExpiration;
        domainObj.owner = msg.sender;
        domainObj.ip = ip;
        domainObj.exists = true;
        
        //update the reeipts array
        Receipt memory receipt = Receipt({amountPaidWei: price, timestamp: now, expires: domainObj.expires});
        receipts[msg.sender].push(receipt);
        
        //but it is required to show that this indeed is an event and not a function call
        emit LogDomainRegistered(msg.sender, domain, domainObj.expires, price);
    }
    
    function edit(bytes domain, bytes4 newIp) public onlyDomainOwner(domain) domainNotExpired(domain) {
        _getDomain(domain).ip = newIp;
        
        emit LogDomainRedirected(domain, newIp);
    }
    
    function transferDomain(bytes domain, address newOwner) public onlyDomainOwner(domain) domainNotExpired(domain) addressValid(newOwner) {
        Domain storage domainObj = _getDomain(domain);
        
        emit LogOwnershipTransferred(domainObj.owner, newOwner, domain);
        
        domainObj.owner = newOwner;
    }
    
    function getIP(bytes domain) public domainNotExpired(domain) view returns (bytes4) {
        return(_getDomain(domain).ip);
    }
    
    function getPrice(bytes domain) public domainLongEnough(domain) pure returns (uint) {
        uint extraPay;
        if(domain.length <= minDomainLength*2){
            //pay 200 extra finney for each character in the domain less than minDomainLength * 2;
            extraPay = (minDomainLength*2 - domain.length) * (domainBasePrice / minDomainLength);
        }
        
        return domainBasePrice + extraPay;
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }
}
