const util = {
	expectThrow: async promise => {
		try {
			let result = await promise;
		} catch (error) {
			const invalidJump = error.message.search('invalid JUMP') >= 0
			const invalidOpcode = error.message.search('invalid opcode') >= 0
			const outOfGas = error.message.search('out of gas') >= 0
			const revert = error.message.search('revert') >= 0
			assert(invalidJump || invalidOpcode || outOfGas || revert, "Expected throw, got '" + error + "' instead")
			return
		}
		assert.fail('Expected throw not received')
	},

	web3Now: (web3) => {
		return web3.eth.getBlock(web3.eth.blockNumber).timestamp;
	},

	web3FutureTime: (web3) => {
		return web3.eth.getBlock(web3.eth.blockNumber).timestamp + 60 * 60;
	},

	timeTravel: (web3, seconds) => {
		return new Promise((resolve, reject) => {
			web3.currentProvider.sendAsync({
				jsonrpc: "2.0",
				method: "evm_increaseTime",
				params: [seconds], // 86400 seconds in a day
				id: new Date().getTime()
			}, (err, result) => {
				if (err) {
					reject(err);
				}
				web3.currentProvider.sendAsync({
					jsonrpc: "2.0",
					method: "evm_mine",
					id: new Date().getTime()
				}, function (err, result) {
					if (err) {
						reject(err);
					}
					resolve(result);
				});

			});
		})
	}
}


module.exports = util;