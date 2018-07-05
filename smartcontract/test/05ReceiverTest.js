var ViddoToken = artifacts.require("ViddoToken");
var ViddoSale = artifacts.require("ViddoSale");
require("babel-polyfill")

var chai = require("chai")
var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
expect = chai.expect;

var viddoTokenContract = 0;
var viddoReceiver = 0;
var viddoSaleContract = 0;
var totalSupply = 0;
var owner = 0;
var rate = 1;

console.log();
contract("05. Testing Receiver Functionality",   async (accounts)=>{
     describe("Deploy Viddo Token Smart Contract",    function () {
      it("Catch an instance of Viddo Token Smart Contract", function() {
      return ViddoToken.new().then(function(instance) {
        viddoTokenContract = instance
        console.log('    Viddo Token:'.blue,viddoTokenContract.address)
      });
    })
  });

     describe("Generate New Receiver.",   async () => {
      it("Catch new receiver address and add it as receiver", async() => {
      viddoReceiver = await viddoTokenContract.GenerateReceiver.call();
      console.log('    Viddo Receiver:'.red,viddoReceiver)
      expect(viddoReceiver).to.be.not.null;

    })
      it("Check if receiver is marked as receiver", async() => {
        var receiver = await viddoTokenContract.GenerateReceiver.call();
        console.log(receiver)
        var isR = await viddoTokenContract.IsReceiver.call(receiver)
        console.log('    Viddo Receiver:'.green,isR)
        expect(isR).to.be.true

    })
  });


});
