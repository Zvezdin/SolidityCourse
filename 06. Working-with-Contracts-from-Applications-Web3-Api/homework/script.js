//this function will be called when the whole page is loaded
window.onload = function(){
	if (typeof web3 === 'undefined') {
		//if there is no web3 variable
		displayMessage("Error! Are you sure that you are using metamask?");
	} else {
		displayMessage("Welcome to our DAPP!");
		init();
	}
}

var contractInstance;

var abi = [{"constant":true,"inputs":[{"name":"person","type":"address"}],"name":"getPokemonsByPerson","outputs":[{"name":"","type":"uint8[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"pokemon","type":"uint8"}],"name":"getPokemonHolders","outputs":[{"name":"","type":"address[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"pokemon","type":"uint8"}],"name":"catchPokemon","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"by","type":"address"},{"indexed":true,"name":"pokemon","type":"uint8"}],"name":"LogPokemonCaught","type":"event"}];

var address = "0x8cdaf0cd259887258bc13a92c0a6da92698644c0";
var acc;

function init(){
	var Contract = web3.eth.contract(abi);
	contractInstance = Contract.at(address);
	updateAccount();
}

function updateAccount(){
	//in metamask, the accounts array is of size 1 and only contains the currently selected account. The user can select a different account and so we need to update our account variable
	acc = web3.eth.accounts[0];
}

function displayMessage(message){
	var el = document.getElementById("message");
	el.innerHTML = message;
}

function getTextInput(){
	var el = document.getElementById("input");
	
	return el.value;
}

function onButtonPressed(){
	updateAccount();

	//input should be a valid pokemon index.
	//we cannot check if the input is out of bounds, though.
	var input = getTextInput();

	contractInstance.catchPokemon(input, {"from": acc}, function(err, res){
		if(!err){
			displayMessage("Success! Transaction hash: " + res.valueOf());
		} else {
			displayMessage("Something went wrong. Are you sure that it's been 15 seconds or you don't own it yet?");
			console.error(err);
		}
	});
}

function onSecondButtonPressed(){
	updateAccount();	

	var input = getTextInput();
	
	var accountInput;
	
	accountInput = input.startsWith("0x");
	
	if(accountInput){
		contractInstance.getPokemonsByPerson.call(input, {"from": acc}, function(err, res) {
		if(!err){
			displayMessage("This account owns the following pokemons: " + res);
		} else {
			displayMessage("Something went horribly wrong:", err);
		}
	});
	} else {
		contractInstance.getPokemonHolders.call(input, {"from": acc}, function(err, res) {
			if(!err){
				displayMessage("This pokemon is owned by the following adresses: " + res);
			} else {
				displayMessage("Something went horribly wrong:", err);
			}
		});
	}
}