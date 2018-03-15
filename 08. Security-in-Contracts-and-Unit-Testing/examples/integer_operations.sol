pragma solidity 0.4.21;

contract Test {
    uint public a = 5;
    uint public b = 2;
    //5 / 2 is 2, if 5 and 2 are variables
    uint public c = (a / b) * 10; //res: 20
    // 5 / 2 is 2.5 if 5 and 2 are literals
    uint public d = (5 / 2) * 10; //res: 25
}
