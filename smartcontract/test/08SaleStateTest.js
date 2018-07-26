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

console.log ("  Sale contract state 0 - preico 1 -  icorunning, 2- icopaused, 3 - icofinished 4 -  postico.".green)
contract("08. Testing Sale Contract state change and sale.",    (accounts)=>{
     describe("Deploy Viddo Token Smart Contract and ViddoSale Contract",    function () {

      it("Catch an instance of Viddo Token Smart Contract & Viddo Sale Smart Contract", function() {
      return ViddoToken.new().then(function(instance) {
        viddoTokenContract = instance
        return ViddoSale.new(rate,accounts[0],viddoTokenContract.address).then((instance2)=>{
          viddoSaleContract = instance2;
           console.log('    Viddo Token:'.blue,viddoTokenContract.address)
           console.log('    Viddo Sale:'.blue,viddoSaleContract.address)
        })
      });
    })

    it("Change Sale Contract State to preico", () => {
      return viddoSaleContract.setSaleState(0).then((res)=>{
        return viddoSaleContract.getSaleState().then((res2)=>{
          expect(parseInt(res2)).to.be.equal(0)
        })
      })
    })

    it("Change Sale Contract State to icorunning", () => {
      return viddoSaleContract.setSaleState(1).then((res)=>{
        return viddoSaleContract.getSaleState().then((res2)=>{
          expect(parseInt(res2)).to.be.equal(1)
        })
      })
    })
    it("Change Sale Contract State to icopaused", () => {
      return viddoSaleContract.setSaleState(2).then((res)=>{
        return viddoSaleContract.getSaleState().then((res2)=>{
          expect(parseInt(res2)).to.be.equal(2)
        })
      })
    })

    it("Change Sale Contract State to icofinished", () => {
      return viddoSaleContract.setSaleState(3).then((res)=>{
        return viddoSaleContract.getSaleState().then((res2)=>{
          expect(parseInt(res2)).to.be.equal(3)
        })
      })
    })

    it("Change Sale Contract State to postico", () => {
      return viddoSaleContract.setSaleState(4).then((res)=>{
        return viddoSaleContract.getSaleState().then((res2)=>{
          expect(parseInt(res2)).to.be.equal(4)
        })
      })
    })

    it("Change Sale Contract State to undfined state. Should fail", () => {
      expect(viddoSaleContract.setSaleState(5)).to.be.rejected
    })

    it("Adding Sale Contract address to whitelist",()=>{
    expect(viddoTokenContract.addToWhitelist(viddoSaleContract.address,{"from":accounts[0]})).to.be.eventually.fulfilled
    })

    it("Transfering 100 tokens to Sale Contract.",()=>{
    expect(viddoTokenContract.transfer(viddoSaleContract.address,100,{"from":accounts[0]})).to.be.eventually.fulfilled
    })

    it("Add accounts[1] to whitelist must be fulfilled",()=>{
    expect(viddoTokenContract.addToWhitelist(accounts[1],{"from":accounts[0]})).to.be.eventually.fulfilled
    })

    console.log ("  Sale contract state 0 - preico 1 -  icorunning, 2- icopaused, 3 - icofinished 4 -  postico.".green)

    it("Buying transaction should succeed. Accounts[1] is ON the whitelist and state is postico",()=>{
    return expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":1})).to.be.fulfilled;
  })

    it("Buying transaction should fail. Accounts[1] is ON the whitelist and state is preico",()=>{
      return viddoSaleContract.setSaleState(0).then((res)=>{
        expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":1})).to.be.rejected;
      })
    })
    it("Buying transaction should fail. Accounts[1] is ON the whitelist and state is icopaused",()=>{
      return viddoSaleContract.setSaleState(2).then((res)=>{
        expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":1})).to.be.rejected;
      })
    })
    it("Buying transaction should fail. Accounts[1] is ON the whitelist and state is icofinished",()=>{
      return viddoSaleContract.setSaleState(3).then((res)=>{
        expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":1})).to.be.rejected;
      })
    })

    it("Buying transaction should succeed. Accounts[1] is ON the whitelist and state is icorunning",()=>{
      return viddoSaleContract.setSaleState(1).then((res)=>{
        expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":1})).to.be.fulfilled;
      })
    })

    it("Accounts[1] should have two tokens",()=>{
      return viddoTokenContract.balanceOf(accounts[1]).then((res)=>{
        expect (parseInt(res)).to.be.equal(2);
      })
    })

  });
})
