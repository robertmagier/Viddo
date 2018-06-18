var ViddoToken = artifacts.require("./ViddoToken.sol");

module.exports = function(deployer) {
  deployer.deploy(ViddoToken);
};
