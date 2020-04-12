const DDNS = artifacts.require("DDNS");
const expectThrow = require('./util').expectThrow;
const timeTravel = require('./util').timeTravel;

contract('DDNS', function (accounts) {

	let ddnsInstance;

	const _owner = accounts[0];
	const _notOwner = accounts[1];
	const _buyer = accounts[5];
	let points = 0;
	let totalPoints = 0;

	const firstDomainName = 'pesho_e_velik.bg';
	const firstDomainIP = '0x12121212'
	const secondDomainName = 'goo.gl';
	const secondDomainIP = '0xafafafaf'
	const tooShortDomainName = 'aaaaa';
	const tooShortIP = '0x13131313';


	describe("Registering domain", () => {
		beforeEach(async function () {
			ddnsInstance = await DDNS.new({
				from: _owner
			});
		})

		it("should return the cost of registering a domain", async function () {
			totalPoints += 2;
			const res = await ddnsInstance.getPrice(firstDomainName);
			assert(res.gte(web3.toWei(1, "ether")));
			points += 2;
		});

		it("should add new domain correctly", async function () {
			totalPoints += 3;
			const firstCost = await ddnsInstance.getPrice(firstDomainName);

			const receipt1 = await ddnsInstance.register(firstDomainName, firstDomainIP, {value: firstCost});
			assert(receipt1.receipt.status == 1, 'Unsuccessful registration of First Domain');

			const secondCost = await ddnsInstance.getPrice(secondDomainName);
			const receipt2 = await ddnsInstance.register(secondDomainName, secondDomainIP, {value: secondCost});
			assert(receipt2.receipt.status == 1, 'Unsuccessful registration of Second Domain');
			points += 3;
		});

		it("should throw on not enough pay", async function () {
			totalPoints += 2;
			const cost = await ddnsInstance.getPrice(firstDomainName);
			await expectThrow(ddnsInstance.register(firstDomainName, firstDomainIP, {value: cost.sub(1)}));
			points += 2;
		});

		it("should not register existing domains", async function () {
			totalPoints += 3;
			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			const receipt = await ddnsInstance.register(firstDomainName, firstDomainIP, {from: _notOwner, value: firstCost});

			await expectThrow(ddnsInstance.register(firstDomainName, firstDomainIP, {from: _buyer, value: firstCost}));
			points += 3;
		})
		
		it("domain should expire in 1 year", async function () {
			totalPoints += 3;
			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			const receipt = await ddnsInstance.register(firstDomainName, firstDomainIP, {from: _notOwner, value: firstCost});
			await timeTravel(web3, 31557601);
			const rec = await ddnsInstance.register(firstDomainName, firstDomainIP, {from: _buyer, value: firstCost});
			assert(rec.receipt.status == 1, "Domain didn't expire")
			points += 3;
		});

		it("should extend domain expiration", async function () {
			totalPoints += 3;
			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			await ddnsInstance.register(firstDomainName, firstDomainIP, {from: _notOwner, value: firstCost});
			await ddnsInstance.register(firstDomainName, firstDomainIP, {from: _notOwner, value: firstCost});
			await timeTravel(web3, 31557601);
			await expectThrow(ddnsInstance.register(firstDomainName, firstDomainIP, {from: _buyer, value: firstCost}));
			points += 3;
		});

		it("should throw on short domains", async function () {
			totalPoints += 2;
			await expectThrow(ddnsInstance.register(tooShortDomainName, tooShortIP, {from: _notOwner, value: web3.toWei(10, "ether")}));
			points += 2;
		});

		it("should not return back the tip", async function () {
			totalPoints += 2;
			const balanceBefore = await web3.eth.getBalance(ddnsInstance.address);
			
			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			await ddnsInstance.register(firstDomainName, firstDomainIP, {from: _notOwner, value: web3.toWei(10, "ether")});
			
			const balanceAfter = await web3.eth.getBalance(ddnsInstance.address);

			assert(balanceAfter.sub(balanceBefore).gt(firstCost), 'The tip was apparently returned');

			points += 2;
		});

		it("should emit event", async function () {
			totalPoints += 2;
			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			const result = await ddnsInstance.register(firstDomainName, firstDomainIP, {value: firstCost});
			assert.isAtLeast(result.logs.length, 1, 'No event was emitted');
			points += 2;
		})

	});

	describe("Getting domain IP", () => {
		beforeEach(async function () {
			ddnsInstance = await DDNS.new({
				from: _owner
			});

			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			const receipt = await ddnsInstance.register(firstDomainName, firstDomainIP, {value: firstCost});
			const secondCost = await ddnsInstance.getPrice(secondDomainName);
			const receipt2 = await ddnsInstance.register(secondDomainName, secondDomainIP, {value: secondCost});
		})

		it("should return the IP correctly", async function () {
			totalPoints += 5;
			const ip = await ddnsInstance.getIP(firstDomainName);
			assert.equal(ip, firstDomainIP);

			const ip2 = await ddnsInstance.getIP(secondDomainName);
			assert.equal(ip2, secondDomainIP);
			points += 5;
		});

		it("should throw on nonexistent domain", async function () {
			totalPoints += 4;
			await expectThrow(ddnsInstance.getIP("pesho.is.a.good.man"));
			points += 4;
		});

		it("should be callable by anyone", async function () {
			totalPoints += 1;
			const ip = await ddnsInstance.getIP(firstDomainName, {from: _notOwner});
			assert.equal(ip, firstDomainIP);
			points += 1;
		});
	});

	describe("Editing a domain", () => {
		beforeEach(async function () {
			ddnsInstance = await DDNS.new({
				from: _owner
			});

			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			const receipt1 = await ddnsInstance.register(firstDomainName, firstDomainIP, {value: firstCost});
			
			const secondCost = await ddnsInstance.getPrice(secondDomainName);
			const receipt2 = await ddnsInstance.register(secondDomainName, secondDomainIP, {value: secondCost});
		})

		it("should change the IP", async function () {
			totalPoints += 3;
			const rec = await ddnsInstance.edit(firstDomainName, secondDomainIP);
			const ip = await ddnsInstance.getIP(firstDomainName);
			assert.equal(ip, secondDomainIP);
			points += 3;
		});

		it("should throw if domain doesn't exist", async function () {
			totalPoints += 2;
			await expectThrow(ddnsInstance.edit("pessshsheo", secondDomainIP));
			points += 2;
		});

		it("should throw if domain is expired", async function () {
			totalPoints += 2;
			await timeTravel(web3, 31557601);
			await expectThrow(ddnsInstance.edit(firstDomainName, secondDomainIP));
			points += 2;
		});

		it("should throw if domain is owned by someone else", async function () {
			totalPoints += 3;
			await expectThrow(ddnsInstance.edit(firstDomainName, secondDomainIP, {from: _buyer}));
			points += 3;
		});

		it("should emit event", async function () {
			totalPoints += 2;
			const result = await ddnsInstance.edit(firstDomainName, secondDomainIP);
			assert.isAtLeast(result.logs.length, 1, 'No event was emitted');
			points += 2;
		})

	});

	describe("Transferring domain ownership", () => {
		beforeEach(async function () {
			ddnsInstance = await DDNS.new({
				from: _owner
			});

			const firstCost = await ddnsInstance.getPrice(firstDomainName);
			const receipt1 = await ddnsInstance.register(firstDomainName, firstDomainIP, {value: firstCost});
			
			const secondCost = await ddnsInstance.getPrice(secondDomainName);
			const receipt2 = await ddnsInstance.register(secondDomainName, secondDomainIP, {value: secondCost});
		})

		it("should transfer ownership", async function () {
			totalPoints += 3;
			await ddnsInstance.transferDomain(firstDomainName, _notOwner);
			await expectThrow(ddnsInstance.edit(firstDomainName, secondDomainIP));
			const res = await ddnsInstance.edit(firstDomainName, secondDomainIP, {from: _notOwner});
			assert(res.receipt.status == 1, "Ownership wasn't transferred")
			points += 3;
		});

		it("should be callable only by domain owner", async function () {
			totalPoints += 3;
			await expectThrow(ddnsInstance.transferDomain(firstDomainName, _notOwner, {from: _buyer}));
			points += 3;
		});

		it("should throw on non-existing domain", async function () {
			totalPoints += 2;
			await expectThrow(ddnsInstance.transferDomain("peshshsheoo", _notOwner));
			points += 2;
		});

		it("should throw on expired domain", async function () {
			totalPoints += 2;
			await timeTravel(web3, 31557601);
			await expectThrow(ddnsInstance.transferDomain(firstDomainName, _notOwner));
			points += 2;
		});

		it("should emit event", async function () {
			totalPoints += 1;
			const result = await ddnsInstance.transferDomain(firstDomainName, _notOwner);
			assert.isAtLeast(result.logs.length, 1, 'No event was emitted');
			points += 1;
		})


	});

	describe("Listing receipts of addresses", () => {
		let firstCost;
		let secondCost;
		beforeEach(async function () {
			ddnsInstance = await DDNS.new({
				from: _owner
			});

			firstCost = await ddnsInstance.getPrice(firstDomainName);
			const receipt1 = await ddnsInstance.register(firstDomainName, firstDomainIP, {value: firstCost});
			
			secondCost = await ddnsInstance.getPrice(secondDomainName);
			const receipt2 = await ddnsInstance.register(secondDomainName, secondDomainIP, {from: _notOwner, value: secondCost});
			const receipt3 = await ddnsInstance.register(secondDomainName, secondDomainIP, {from: _notOwner, value: secondCost});
			const receipt4 = await ddnsInstance.register(secondDomainName, secondDomainIP, {from: _notOwner, value: secondCost});
		})

		it("should list the correct receipts", async function () {
			totalPoints += 8;

			const rec1 = await ddnsInstance.receipts.call(_owner, 0);
			assert(rec1[0].eq(firstCost));

			await expectThrow(ddnsInstance.receipts.call(_owner, 1));
			points += 2;

			for(let i=0; i<=2; i++){
				const rec2 = await ddnsInstance.receipts.call(_notOwner, 0);
				assert(rec2[0].eq(secondCost));
			}
			await expectThrow(ddnsInstance.receipts.call(_notOwner, 3));
			points += 6;
		});

		it("should throw if account hasn't purchased a domain", async function () {
			totalPoints += 2;
			await expectThrow(ddnsInstance.receipts.call(_buyer, 0));
			points += 2;
		});
	});

	describe("Having dynamic pricing", () => {
		let firstProductId;
		beforeEach(async function () {
			ddnsInstance = await DDNS.new({
				from: _owner
			});
		})

		it("should provide different price values for short and long domains", async function () {
			totalPoints += 4;
			const val1 = await ddnsInstance.getPrice(firstDomainName);
			const val2 = await ddnsInstance.getPrice(secondDomainName);

			//not equal
			assert(val1 != val2);

			points += 4;
		});

		it("should throw on too short domains", async function (){
			totalPoints += 1;
			await expectThrow(ddnsInstance.getPrice(tooShortDomainName));
			points += 1;
		});
	});

	describe("Witdhraw", () => {
		beforeEach(async function () {
			ddnsInstance = await DDNS.new({
				from: _owner
			});
			
			const cost = await ddnsInstance.getPrice(firstDomainName);
			await ddnsInstance.register(firstDomainName, firstDomainIP, {value: cost});
		});

		it("should be able to withdraw", async function () {
			totalPoints += 3;
			const balanceBefore = await web3.eth.getBalance(_owner);

			let result = await ddnsInstance.withdraw();
			const balanceAfter = await web3.eth.getBalance(_owner);
			assert(balanceAfter.gt(balanceBefore), 'No Withdraw');
			points += 3;
		});

		it("should not withdraw from non_owner", async function () {
			totalPoints += 2;
			const balanceBefore = await web3.eth.getBalance(_owner);
			
			let result = await ddnsInstance.withdraw();
			const balanceAfter = await web3.eth.getBalance(_owner);
			assert(balanceAfter.gt(balanceBefore), 'No withdraw');
			
			await expectThrow(ddnsInstance.withdraw({
				from: _notOwner
			}));
			points += 2;
		});

	});


	after(function () {
		console.log(`\n\n======= Final result: ${points}/${totalPoints} =======`);
	})
});