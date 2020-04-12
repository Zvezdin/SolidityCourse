const Marketplace = artifacts.require("Marketplace");
const expectThrow = require('./util').expectThrow;
const timeTravel = require('./util').timeTravel;

contract('Marketplace', function (accounts) {

	let marketplaceInstance;

	const _owner = accounts[0];
	const _notOwner = accounts[1];
	const _buyer = accounts[5];
	let points = 0;
	let totalPoints = 0;

	const firstProductName = 'First Product';
	const secondProductName = 'Second Product';
	const firstPrice = 100000000000000000;
	const secondPrice = 200000000000000000;
	const firstQty = 10;
	const secondQty = 3;


	describe("Adding product", () => {
		beforeEach(async function () {
			marketplaceInstance = await Marketplace.new({
				from: _owner
			});
		})

		it("should add new product correctly", async function () {
			totalPoints += 3;
			const receipt1 = await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);
			assert(receipt1.receipt.status == 1, 'Unsuccessful addition of First Product');

			const receipt2 = await marketplaceInstance.newProduct(secondProductName, secondPrice, secondQty);
			assert(receipt2.receipt.status == 1, 'Unsuccessful addition of Second Product');
			points += 3;
		})

		it("should not override existing products", async function () {
			totalPoints += 3;
			const receipt1 = await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);
			await expectThrow(marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty));
			points += 3;
		})

		it("should not be called from non-owner", async function () {
			totalPoints += 2;
			await expectThrow(marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty, {
				from: _notOwner
			}));
			points += 2;
		})

		it("should not accept invalid values", async function () {
			totalPoints += 2;
			await expectThrow(marketplaceInstance.newProduct('', firstPrice, firstQty));
			points += 2;
		})

		it("should emit event", async function () {
			totalPoints += 2;
			const result = await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);
			assert.isAtLeast(result.logs.length, 1, 'No event was emitted');
			points += 2;
		})


	});

	describe("Getting Products", () => {
		beforeEach(async function () {
			marketplaceInstance = await Marketplace.new({
				from: _owner
			});

			await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);
			await marketplaceInstance.newProduct(secondProductName, secondPrice, secondQty);
		})

		it("should return products correctly", async function () {
			totalPoints += 5;
			let products = await marketplaceInstance.getProducts.call();

			assert.lengthOf(products, 2, "Incorrect length of products");
			points += 5;
		})

		it("should be callable by anyone", async function () {
			totalPoints += 5;
			let products = await marketplaceInstance.getProducts.call({
				from: _notOwner
			});

			assert.lengthOf(products, 2, "Incorrect length of products");
			points += 5;
		})

	});

	describe("Getting a product data", () => {
		let firstProductId;
		let secondProductId;
		beforeEach(async function () {
			marketplaceInstance = await Marketplace.new({
				from: _owner
			});

			await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);
			await marketplaceInstance.newProduct(secondProductName, secondPrice, secondQty);

			let products = await marketplaceInstance.getProducts.call();
			firstProductId = products[0];
			secondProductId = products[1];
		})

		it("should return product data correctly", async function () {
			totalPoints += 5;
			const productData1 = await marketplaceInstance.getProduct(firstProductId);
			assert.strictEqual(firstProductName, productData1[0], 'Incorrect name of the product');
			assert(productData1[1].eq(firstPrice), 'Incorrect price of the product');
			assert(productData1[2].eq(firstQty), 'Incorrect quantity of the product');

			const productData2 = await marketplaceInstance.getProduct(secondProductId);
			assert.strictEqual(secondProductName, productData2[0], 'Incorrect name of the product');
			assert(productData2[1].eq(secondPrice), 'Incorrect price of the product');
			assert(productData2[2].eq(secondQty), 'Incorrect quantity of the product');
			points += 5;
		})

		it("should be callable by anyone", async function () {
			totalPoints += 1;
			const productData1 = await marketplaceInstance.getProduct(firstProductId, {
				from: _notOwner
			});
			assert.strictEqual(firstProductName, productData1[0], 'Incorrect name of the product');
			assert(productData1[1].eq(firstPrice), 'Incorrect price of the product');
			assert(productData1[2].eq(firstQty), 'Incorrect quantity of the product');
			points += 1;
		})

		it("should throw on non-existant product", async function () {
			totalPoints += 4;
			await expectThrow(marketplaceInstance.getProduct('incorrect'));
			points += 4;
		})

	});

	describe("Buying product data", () => {
		let firstProductId;
		let secondProductId;
		beforeEach(async function () {
			marketplaceInstance = await Marketplace.new({
				from: _owner
			});

			await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);
			await marketplaceInstance.newProduct(secondProductName, secondPrice, secondQty);

			let products = await marketplaceInstance.getProducts.call();
			firstProductId = products[0];
			secondProductId = products[1];
		})

		it("should buy product", async function () {
			totalPoints += 4;
			await marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice * 2
			})

			const productData1 = await marketplaceInstance.getProduct(firstProductId);
			assert(productData1[2].eq(firstQty - 2), 'Incorrect quantity of the product');

			points += 4;
		})

		it("should allow anyone to buy product", async function () {
			totalPoints += 2;
			await marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice * 2,
				from: _buyer
			})

			const productData1 = await marketplaceInstance.getProduct(firstProductId);
			assert(productData1[2].eq(firstQty - 2), 'Incorrect quantity of the product');

			points += 2;
		})

		it("should throw on non-existing product", async function () {
			totalPoints += 4;
			await expectThrow(marketplaceInstance.buy('firstProductId', 2, {
				value: firstPrice * 2,
				from: _buyer
			}))

			points += 4;
		})

		it("should throw on not enought quantity", async function () {
			totalPoints += 4;
			await expectThrow(marketplaceInstance.buy(firstProductId, 2 * firstQty, {
				value: firstPrice * 2 * firstQty,
				from: _buyer
			}))

			points += 4;
		})

		it("should throw on not enought value sent", async function () {
			totalPoints += 4;
			await expectThrow(marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice,
				from: _buyer
			}))

			points += 4;
		})

		it("should not return back the tip", async function () {
			totalPoints += 2;
			const balanceBefore = await web3.eth.getBalance(marketplaceInstance.address);
			await marketplaceInstance.buy(firstProductId, 1, {
				value: firstPrice * 2,
				from: _buyer
			})

			const balanceAfter = await web3.eth.getBalance(marketplaceInstance.address);

			assert(balanceAfter.sub(balanceBefore).gt(firstPrice), 'The tip was apparently returned');

			points += 2;
		})

		it("should emit event", async function () {
			totalPoints += 2;
			const result = await marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice * 2,
				from: _buyer
			})
			assert.isAtLeast(result.logs.length, 1, 'No event was emitted');
			points += 2;
		})

	});

	describe("Updating product", () => {
		let firstProductId;
		let secondProductId;
		beforeEach(async function () {
			marketplaceInstance = await Marketplace.new({
				from: _owner
			});

			await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);
			await marketplaceInstance.newProduct(secondProductName, secondPrice, secondQty);

			let products = await marketplaceInstance.getProducts.call();
			firstProductId = products[0];
			secondProductId = products[1];
		})

		it("should update product correctly", async function () {
			totalPoints += 5;
			await marketplaceInstance.update(firstProductId, 5)
			const productData1 = await marketplaceInstance.getProduct(firstProductId);
			assert(productData1[2].eq(5), 'Incorrectly updated quantity of the product');
			points += 5;
		})

		it("should throw on non-existing products", async function () {
			totalPoints += 3;
			await expectThrow(marketplaceInstance.update('firstProductId', 5));
			points += 3;
		})

		it("should not be called from non-owner", async function () {
			totalPoints += 2;
			await expectThrow(marketplaceInstance.update(firstProductId, 5, {
				from: _notOwner
			}));
			points += 2;
		})

		it("should emit event", async function () {
			totalPoints += 1;
			const result = await marketplaceInstance.update(firstProductId, 5)
			assert.isAtLeast(result.logs.length, 1, 'No event was emitted');
			points += 1;
		})


	});

	describe("Having dynamic pricing", () => {
		let firstProductId;
		beforeEach(async function () {
			marketplaceInstance = await Marketplace.new({
				from: _owner
			});

			await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);

			let products = await marketplaceInstance.getProducts.call();
			firstProductId = products[0];
		})

		it("should update product price correctly after buy", async function () {
			totalPoints += 5;
			const resultBeforeBuy = await marketplaceInstance.getPrice(firstProductId, 2);
			await marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice * 2
			})
			const resultAfterBuy = await marketplaceInstance.getPrice(firstProductId, 2);
			assert(resultAfterBuy.gt(resultBeforeBuy), 'The price has not increased');
			points += 5;
		})

	});

	describe("Ownership and Witdhraw", () => {
		beforeEach(async function () {
			marketplaceInstance = await Marketplace.new({
				from: _owner
			});
			await marketplaceInstance.newProduct(firstProductName, firstPrice, firstQty);

			let products = await marketplaceInstance.getProducts.call();
			firstProductId = products[0];
		})



		it("should be able to withdraw", async function () {
			totalPoints += 3;
			const balanceBefore = await web3.eth.getBalance(_owner);
			await marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice * 2,
				from: _buyer
			})
			let result = await marketplaceInstance.withdraw();
			const balanceAfter = await web3.eth.getBalance(_owner);
			assert(balanceAfter.gt(balanceBefore), 'No Withdraw');
			points += 3;
		});

		it("should not withdraw from non_owner", async function () {
			totalPoints += 2;
			const balanceBefore = await web3.eth.getBalance(_owner);
			console.log("Buying first");
			await marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice * 2,
				from: _buyer
			})
			console.log("Done first");
			let result = await marketplaceInstance.withdraw();
			console.log("withdrawn first");
			const balanceAfter = await web3.eth.getBalance(_owner);
			assert(balanceAfter.gt(balanceBefore), 'No kill function');
			console.log("Buying second");
			console.log(await marketplaceInstance.getProduct(firstProductId));
			await marketplaceInstance.buy(firstProductId, 2, {
				value: firstPrice * 3, //*3, because the price will be a little higher than *2 due to dynamic pricing
				from: _buyer
			})
			console.log("Done second");
			await expectThrow(marketplaceInstance.withdraw({
				from: _notOwner
			}));
			points += 2;
		});

	});


	after(function () {
		console.log(`\n\n======= Final result: ${points}/${totalPoints} =======`);
	})
});