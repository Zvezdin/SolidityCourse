const ico = artifacts.require("SimpleICO");

const increaseTime = function(duration) {
  const id = Date.now() / 1000 | 0;

  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: '2.0',
      method: 'evm_increaseTime',
      params: [duration],
      id: id,
    }, err1 => {
      if (err1) return reject(err1)

      web3.currentProvider.sendAsync({
        jsonrpc: '2.0',
        method: 'evm_mine',
        id: id+1,
      }, (err2, res) => {
        return err2 ? reject(err2) : resolve(res)
      })
    })
  })
}

contract('ICO test', async (accounts) => {
	it("shoud init init with contract balance of 1000 tokens", async () => {
		let ins = await ico.deployed();

		let bal = await ins.balanceOf(ins.address);

		assert.equal(bal, 1000);
	})
	
	it("should buy presale tokens", async () => {
		let ins = await ico.deployed();
		
		var acc = accounts[0];
		
		await ins.buy({from: acc, value: web3.toWei(3500, "finney")});
					 
		let tokenBal = await ins.allowance(ins.address, acc);

		assert.equal(tokenBal, 3);
	})
	
	it("should buy ico tokens", async () => {
		let ins = await ico.deployed();
		
		await increaseTime(60*62);
		
		var acc = accounts[1];
		
		await ins.buy({from: acc, value: web3.toWei(4500, "finney")});
					 
		let tokenBal = await ins.allowance(ins.address, acc);

		assert.equal(tokenBal, 2);
	})
	
	it("should block transfer", async () => {
		let ins = await ico.deployed();
		
		try{
			await ins.transfer("0x123", "3");
			assert(true, "");
		} catch(e) {
			return;
		}
		
		assert(false, "transfer is not blocked");
	})
	
	it("should block transferFrom", async () => {
		let ins = await ico.deployed();
		
		try{
			await ins.transferFrom(ins.address, "0x123", "3");
			assert(true, "");
		} catch(e) {
			return;
		}
		
		assert(false, "transferFrom is not blocked");
	})
	
	it("should block approve", async () => {
		let ins = await ico.deployed();
		
		try{
			await ins.approve("0x123", "3");
			assert(true, "");
		} catch(e) {
			return;
		}
		
		assert(false, "approve is not blocked");
	})
	
	it("should withdraw tokens", async () => {
		let ins = await ico.deployed();
		
		await increaseTime(122*60);
		
		var acc = accounts[0];
		
		await ins.transferFrom(ins.address, acc, 3);
		
		let bal = await ins.balanceOf(acc);
		
		assert.equal(bal.valueOf(), 3, "the withdraw didn't happen");
	})
	
	it("should transfer tokens", async () => {
		let ins = await ico.deployed();
		
		var acc = accounts[0];
		var acc2 = accounts[2];
		
		let bal1 = await ins.balanceOf(acc);
		
		let bal2 = await ins.balanceOf(acc2);
		
		await ins.transfer(acc2, 2, {from: acc});
		
		let bal1_after = await ins.balanceOf(acc);
		let bal2_after = await ins.balanceOf(acc2);
		
		assert.equal(bal1.sub(2).valueOf(), bal1_after.valueOf(), "The transfer didn't happen");
		assert.equal(bal2.add(2).valueOf(), bal2_after.valueOf(), "The transfer didn't happen");
	})
})
