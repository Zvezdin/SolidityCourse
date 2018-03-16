var Pokemon = artifacts.require("Pokemons");

module.exports = function(deployer) {
  deployer.deploy(Pokemon);
};
