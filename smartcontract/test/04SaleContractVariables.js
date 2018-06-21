var ViddoToken = artifacts.require("ViddoToken");
var ViddoSale = artifacts.require("ViddoSale");
require("babel-polyfill")

var chai = require("chai")
var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
expect = chai.expect;

var viddoTokenContract = 0;
var viddoSaleContract = 0;
var totalSupply = 0;
var owner = 0;
var rate = 1;

console.log();
contract("Testing Allowance and Approval Process + Increase and Decrease Approval. ", async(accounts)=>{
  describe("Deploy Viddo Token Smart Contract and ViddoSale Contract",  function () {
    it("Catch an instance of Viddo Token Smart Contract & Viddo Sale Smart Contract", function() {
      return ViddoToken.new().then(function(instance) {
        viddoTokenContract = instance
        return ViddoSale.new(rate,accounts[0],viddoTokenContract.address).then(async(instance)=>{
          viddoSaleContract = instance;
          await console.log('One more test finished')
          console.log('Viddo Token:',viddoTokenContract.address)
          await console.log('Viddo Sale:',viddoSaleContract.address)
        })
      });
    })
  });

  describe("Checking Viddo Sale variables",async()=>{
    await it("Rate value should be set as in constructor:" + rate,async()=>{
      let r = await viddoSaleContract.rate.call();
      return expect(parseInt(r)).to.be.equal(rate)
    })
  })
});
