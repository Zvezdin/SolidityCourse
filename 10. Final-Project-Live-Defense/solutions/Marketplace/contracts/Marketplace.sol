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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

library ProductLib {
    using SafeMath for uint;
    
    struct Product {
        string name;
        uint price;
        uint quantity;
        bool exists;
    }
    
    function decreaseQuantity(Product storage self, uint quantity) public {
        self.quantity = self.quantity.sub(quantity);
    }
    
    function setQuantity(Product storage self, uint quantity) public {
        self.quantity = quantity;
    }
    
    //this may be an expensive function. You should make the decision of using it or initializing by yourself
    function init(Product storage self, string name, uint price, uint quantity) public {
        self.name = name;
        self.price = price;
        self.quantity = quantity; 
        self.exists = true;
    }
    
    function getPrice(Product storage self, uint quantity, uint minPriceQuantity, uint priceIncreasePerItem) public view returns(uint) {
        uint price = self.price;

        if(self.quantity < minPriceQuantity) {
            //(minPriceQuantity - self.quantity) * priceIncreasePerItem is the percentage with which we need to increase the price
            //so we multiply it by the price and divide by 100 AFTER
            price = price + (price * ((minPriceQuantity - self.quantity) * priceIncreasePerItem)) / 100;
        }

        return price.mul(quantity);
    }
}

contract Marketplace is Ownable {
    using ProductLib for ProductLib.Product;
    using SafeMath for uint;
    
    event ProductPurchase(bytes32 indexed ID, address indexed buyer, uint quantity, uint paid);
    event ProductCreation(bytes32 indexed ID);
    event ProductUpdate(bytes32 indexed ID, uint newQuantity);
    
    mapping(bytes32 => ProductLib.Product) products;
    bytes32[] productList;
    
    //the point of the minimum, standart price. Any quantity less than that will raise the price
    uint constant minPriceQuantity = 10;
    //increase the price by 10% for every item in stock less than minPriceQuantity
    uint constant priceIncreasePerItem = 10;

    modifier enoughQuantity(bytes32 ID, uint q) {
        require(products[ID].quantity >= q);
        _;
    }
    
    modifier productExists(bytes32 ID) {
        require(products[ID].exists);
        _;
    }
    
    modifier validProduct(string name) {
        //to get the length of a string, first cast to bytes.
        //keep in mind that this is accessing the low-level bytes of the UTF-8 representation, and not the individual characters
        require(bytes(name).length > 0);
        _;
    }

    function buy(bytes32 ID, uint quantity) public enoughQuantity(ID, quantity) payable {
        uint pay = getPrice(ID, quantity);
        require(msg.value >= pay);
        
        products[ID].decreaseQuantity(quantity);

        emit ProductPurchase(ID, msg.sender, quantity, pay);
    }
    
    function update(bytes32 ID, uint newQuantity) public productExists(ID) onlyOwner {
        products[ID].quantity = newQuantity;

        emit ProductUpdate(ID, newQuantity);
    }
    
    //creates a new product and returns its ID
    function newProduct(string name, uint price, uint quantity) public onlyOwner validProduct(name) returns(bytes32 ID) {
        ID = keccak256(name, price, quantity, now);
        
        require(!products[ID].exists);

        products[ID] = ProductLib.Product({name: name, price: price, quantity: quantity, exists: true});
        productList.push(ID);

        emit ProductCreation(ID);
    }
    
    function getProduct(bytes32 ID) public productExists(ID) view returns(string name, uint price, uint quantity) {
        ProductLib.Product memory product = products[ID];
        
        name = product.name;
        price = product.price;
        quantity = product.quantity;
    }
    
    function getProducts() public view returns(bytes32[]) {
        return productList;
    }
    
    function getPrice(bytes32 ID, uint quantity) public view productExists(ID) returns (uint) {
        return products[ID].getPrice(quantity, minPriceQuantity, priceIncreasePerItem);
    }

    function withdraw() public onlyOwner {
        require(address(this).balance > 0);
        msg.sender.transfer(address(this).balance);
    }
}


