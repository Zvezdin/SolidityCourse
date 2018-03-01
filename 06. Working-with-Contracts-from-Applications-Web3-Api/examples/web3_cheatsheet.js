//More info on: https://github.com/ethereum/wiki/wiki/JavaScript-API


//if you're using node.js, you need to load the Web3 library
var Web3 = require("web3");
//create a web3 instance - one that is connected to a local node
//the port (9545) may be different depending on your local node. This works for Truffle
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:9545"));

//getting the web3 version
web3.version.api

//getting an array of the node's accounts
web3.eth.accounts

var acc = web3.eth.accounts[0]; //get the first account
var otherAcc = web3.eth.accounts[1];

//We will use the "web3_cheatsheet_contract.sol" contract.

//Store this contract's compiled bytecode and ABI
var abi = [{"constant":false,"inputs":[{"name":"b","type":"uint256"}],"name":"add","outputs":[{"name":"","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"_a","type":"uint256"}],"name":"Util","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getA","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_a","type":"uint256"}],"name":"setA","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"state","type":"uint256"}],"name":"LogSetState","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"result","type":"uint256"},{"indexed":false,"name":"paidWei","type":"uint256"}],"name":"LogAdding","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"previousOwner","type":"address"},{"indexed":true,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}]
var bytecode = "6060604052336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555061046a806100536000396000f300606060405260043610610078576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680631003e2d21461007d578063742643ef146100a95780638da5cb5b146100cc578063d46300fd14610121578063ee919d501461014a578063f2fde38b1461016d575b600080fd5b61009360048080359060200190919050506101a6565b6040518082815260200191505060405180910390f35b34156100b457600080fd5b6100ca6004808035906020019091905050610210565b005b34156100d757600080fd5b6100df61021c565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561012c57600080fd5b610134610241565b6040518082815260200191505060405180910390f35b341561015557600080fd5b61016b600480803590602001909190505061024b565b005b341561017857600080fd5b6101a4600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919050506102e9565b005b600080670de0b6b3a7640000341115156101bf57600080fd5b826001540190507f48e7acad687bbd059476bea0c69d51ba24f711666ed8cb99cf6068bf48bb690360015434604051808381526020018281526020019250505060405180910390a180915050919050565b6102198161024b565b50565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6000600154905090565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161415156102a657600080fd5b806001819055507f889f8c4a0cec2d62d6fddb6cdf3af9c547630d84cb166a7bd7c80e07da125d8d6001546040518082815260200191505060405180910390a150565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561034457600080fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161415151561038057600080fd5b8073ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a3806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550505600a165627a7a72305820cf7b999bd463829243a2df8d48fb26860dff514722ca64e8fc98de272963c7fa0029"

//create the contract instance. We can use this instance to publish or connect to a published contract
var Contract = web3.eth.contract(abi);

//create a JS Object (key-value pairs), holding the data we need to publish our contract
var publishData = {
	"from": acc, //the account from which it will be published
	"data": bytecode,
	"gas": 4000000 //gas limit. This should be the same or lower than Ethereum's gas limit
}

//publish the contract, passing a callback that will be called twice. Once when the transaction is sent, and once when it is mined
//the first argument is the constructor argument
Contract.new("123456789123456789", publishData, function(err, contractInstance) {
	if(!err) {
		if(contractInstance.address) { //if the contract has an address aka if the transaction is mined
			console.log("New contract address is :", contractInstance.address);
		}
	} else {
		console.error(err); //something went wrong
	}
});


var contractAdr = "0x123" //replace with real address
//create our contract instance - a connection to a published contract
var contractInstance = Contract.at(contractAdr);

//let's call its "setA" method with the value 123.
//We will pass a callback which will be called when the transaction is mined
contractInstance.setA("123", {"from": acc}, function(err, res) {
	if(!err){
		console.log("Successfully set A to 123!");
	}
});

//let's get the value of a
contractInstance.getA.call({"from": acc}, function(err, res) {
	if(!err){
		//type of res is BigNumber. We can convert to string via .valueOf()
		console.log("The value of A is ", res.valueOf());
	}
})

//we can also call contract functions synchronously.
//This function will return when the call is done or the transaction is mined
var txHash = contractInstance.setA("123456789123456789", {"from": acc});

var res = contractInstance.getA.call({"from": acc});
console.log("A is now ", res.valueOf()); // "123456789123456789"

//let's call the setter from another account. This should fail (we're not the owner)
contractInstance.setA("123", {"from": otherAcc}, function(err, res) {
	if(!err){
		console.log("How is this possible?");
	} else {
		console.error(err); //Error: VM Exception while processing transaction: revert
	}
})

//let's call a payable contract method
//notice how we convert ethers to wei
contractInstance.add("456", {"from": acc, "value": web3.toWei(2, "ether")}, function(err, res){
	if(!err){
		console.log(res.valueOf()); //this will be the TX hash.
		//Web3 cannot access return values from transaction calls!
	} else {
		console.log("Not enough wei!");
	}
});

//let's filter the blockchain for contract events. 
//the callback will be called one event at a time.
//It will scan the whole blockchain for historical events and also watch for new upcoming events
var filterObject = contractInstance.allEvents({fromBlock: 0, toBlock: 'latest'}, function(error, result){
	if (!error){
		console.log("Got log: ", result);
		//result.event -> the name of the event
		//result.args -> parameters of the event
	}
});
//we can also use
//contractInstance.LogSetState(..., ...);
//if we are looking for a certain event


//More info on how to filter logs by the value of an indexed parameter: https://github.com/ethereum/wiki/wiki/JavaScript-API#contract-events

