pragma solidity 0.4.19;

contract Pokemons {
    //a few defined pokemons
    enum Pokemon { Bulbasaur, Ivysaur, Venusaur, Charmander, Charmeleon, Charizard, Squirtle, Wartortle,
    Blastoise, Caterpie, Metapod, Butterfree, Weedle, Kakuna, Beedrill, Pidgey, Pidgeotto, Pidgeot, Rattata, Raticate,
    Spearow, Fearow, Ekans, Arbok, Pikachu, Raichu, Sandshrew, Sandslash, NidoranF, Nidorina, Nidoqueen, NidoranM }
    
    //pokemon catch event. Note the "Log" prefix, which is a standart for event names.
    event LogPokemonCaught(address indexed by, Pokemon indexed pokemon);
    
    //a pokemon can be caught at most once every 15 seconds if not caught already
    modifier canPersonCatch(address person, Pokemon pokemon){
        require(now > players[person].lastCatch + 15 seconds);
        require(!hasPokemon(person, pokemon));
        _;
    }
    
    struct Player {
        Pokemon[] pokemons;
        uint lastCatch; //timestamp
    }
    
    mapping(address => Player) players;
    
    //mapping can't take user-defined types as keys (ex. Pokemon)
    //the key is uint256, because the amount of Pokemons may increase in the future
    //and pass the uint8 range
    mapping(uint => address[]) pokemonHolders;
    
    //the hash of the pokemon holder and the pokemon is the key. This allows constant time lookup of whether a pokemon is caught by a person
    mapping(bytes32 => bool) hasPokemonMap;
    
    //returns if that person has caught a pokemon. It uses the hash of the address and the pokemon so that it can return the answer
    //without loops
    function hasPokemon(address person, Pokemon pokemon) internal view returns (bool) {
        return hasPokemonMap[keccak256(person, pokemon)];
    }
    
    function catchPokemon(Pokemon pokemon) public canPersonCatch(msg.sender, pokemon) {
        players[msg.sender].pokemons.push(pokemon);
        players[msg.sender].lastCatch = now;
        
        pokemonHolders[uint(pokemon)].push(msg.sender);
        
        hasPokemonMap[keccak256(msg.sender, pokemon)] = true;
        
        LogPokemonCaught(msg.sender, pokemon);
    }
    
    function getPokemonsByPerson(address person) public view returns (Pokemon[]) {
        return players[person].pokemons;
    }
    
    function getPokemonHolders(Pokemon pokemon) public view returns (address[]) {
        return pokemonHolders[uint(pokemon)];
    }
}
