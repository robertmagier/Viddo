var ViddoToken = artifacts.require("./ViddoToken.sol");
var ViddoSale = artifacts.require("./ViddoSale.sol");

module.exports = function(deployer,network,accounts) {
  deployer.deploy(ViddoToken).then(function(){
    return deployer.deploy(ViddoSale,1,accounts[0],ViddoToken.address)
  })
};
