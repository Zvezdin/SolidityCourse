pragma solidity 0.4.19;

contract Math{
    
    int state = 0;
    
	function resetState() {
		state = 0;
	}
	
	function getState() returns (int){
		return state;
	}
	
    function add(int b) returns (int){
        state += b;
		
		return state;
    }
    
    function sub(int b) returns (int){
		state -= b;
        
		return state;
    }
    
    function mul(int b) returns (int){
        state *= b;
		
		return state;
    }
    
    function div(int b) returns (int){
        state /= b;
		
		return state;
    }
    
    //Attention! Powers cannot be signed numbers (no floating point in solidity)
    function pow(uint b) returns (int){
        bool positive = state >= 0;
        
        if(!positive){
            state *= -1;
        }
        
        int res = int(uint(state)**b); //warning: Possible integer overflow when raising power and casting uint to an int
        
        if(!positive && b%2 != 0){ //if the passed number is negative and the power is not even
            res *= -1;
        }
        
		state = res;
		
        return state;
    }
    
    function mod(int b) returns (int){
		state = state % b;
	
        return state;
    }
}


