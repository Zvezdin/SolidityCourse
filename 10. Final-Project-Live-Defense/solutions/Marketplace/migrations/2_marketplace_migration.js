var Marketplace = artifacts.require("Marketplace");

var ProductLib = artifacts.require("ProductLib");

module.exports = function (deployer) {
	deployer.deploy(ProductLib);
	deployer.link(ProductLib, Marketplace);
	deployer.deploy(Marketplace);
};