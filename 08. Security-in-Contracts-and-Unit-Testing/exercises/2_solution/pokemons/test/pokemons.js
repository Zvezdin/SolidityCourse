const Pokemons = artifacts.require("Pokemons");

contract('Pokemons test', async (accounts) => {

  it("should claim the 10th pokemon", async () => {
     let instance = await Pokemons.deployed();
     
	 await instance.catchPokemon(10);

	 let pokemons = await instance.getPokemonsByPerson.call(accounts[0]);
     assert.equal(pokemons[0], 10);
  })
})