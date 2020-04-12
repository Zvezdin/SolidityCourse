var DDNS = artifacts.require("DDNS");

module.exports = function (deployer) {
	deployer.deploy(DDNS);
};