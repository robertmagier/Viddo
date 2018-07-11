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
contract("04. Testing Sale Contract",    (accounts)=>{
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
  });

   describe("Checking Viddo Sale variables",   ()=>{
       it("Rate value should be set as in constructor:" + rate,()=>{
      return viddoSaleContract.rate().then(function(res){
        expect(parseInt(res)).to.be.equal(rate)
      });
    })



    it("Sale contract should have zero tokens",()=>{
    return  viddoTokenContract.balanceOf(viddoSaleContract.address).then(function(res) {
      expect(parseInt(res)).to.be.equal(0)
    })
  })

  })

     describe("Checking Viddo Sale Buying Transaction", ()=>{
       it("Buying transaction should be rejected:",()=>{
       return expect(viddoSaleContract.send(100,{"from":accounts[1]})).to.be.eventually.rejected;
    })
       it("Transfering 100 tokens to Sale Contract.",()=>{
       return expect(viddoTokenContract.transfer(viddoSaleContract.address,100,{"from":accounts[0]})).to.be.eventually.fulfilled;
    })

      it("Sale contract should have 100 tokens",()=>{
   return  viddoTokenContract.balanceOf(viddoSaleContract.address).then(function(res) {
     expect(parseInt(res)).to.be.equal(100)
   })
 })

   it("Buying transaction should fail. Accounts[1] is not on the whitelist",()=>{
   return expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":100})).to.be.eventually.rejected;
})

   it("Add accounts[1] to whitelist must be fulfilled",()=>{
   return expect(viddoSaleContract.addToWhitelist(accounts[1],{"from":accounts[0]})).to.be.eventually.fulfilled;
})

  it("Buying transaction should succeed. Accounts[1] is ON the whitelist",()=>{
  return expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":100})).to.be.eventually.fulfilled;
})

    it("Accounts[1] contract should have 100 token",()=>{

 return  viddoTokenContract.balanceOf(accounts[1]).then(function(res) {
   expect(parseInt(res)).to.be.equal(100)
 })
})

  it("Sale contract should have zero tokens",()=>{
return  viddoTokenContract.balanceOf(viddoSaleContract.address).then(function(res) {
 expect(parseInt(res)).to.be.equal(0)
})
})


})

  describe("Checking Adding and Removing from WhiteList",  ()=>{
    it("Sale contract should have zero tokens",()=>{
 return  viddoTokenContract.balanceOf(viddoSaleContract.address).then(function(res) {
   expect(parseInt(res)).to.be.equal(0)
 })
})

  it("Add accounts[1] to whitelist must be fulfilled",()=>{
  return expect(viddoSaleContract.addToWhitelist(accounts[1],{"from":accounts[0]})).to.be.eventually.fulfilled;
})

  it("Transfering 100 tokens to Sale Contract.",()=>{
  return expect(viddoTokenContract.transfer(viddoSaleContract.address,100,{"from":accounts[0]})).to.be.eventually.fulfilled;
})

  it("Buying transaction should succeed. Accounts[1] is ON the whitelist",()=>{
  return expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":1})).to.be.eventually.fulfilled;
})
it("Change rate and see if it was changed",()=>{
  return viddoSaleContract.setRate(30).then(function(res){
    return viddoSaleContract.rate().then(function(res){
      expect(parseInt(res)).to.be.equal(30)
    })
  });
})

it("Transfer 100 tokens to Sale Contract. Set Rate to 30. Send 100 wei and check if 3 tokens were received(100/30 == 3 tokens and 10 wei change)",()=>{
  return viddoTokenContract.transfer(viddoSaleContract.address,100,{"from":accounts[0]}).then((res)=>{
    return viddoSaleContract.setRate(30).then((res)=>{
      return viddoTokenContract.balanceOf(accounts[1]).then((res)=>{
        var balance1 = parseInt (res)
        return viddoSaleContract.sendTransaction({"from":accounts[1],"value":100}).then((res)=>{
          return viddoTokenContract.balanceOf(accounts[1]).then((res)=>{
            expect(parseInt(res)).to.be.equal(balance1+3) //104 = 100 + 1 +3
          })
        })
      })
    })
  })
})

  it("Remove accounts[1] from whitelist must be fulfilled",()=>{
  return expect(viddoSaleContract.removeFromWhitelist(accounts[1],{"from":accounts[0]})).to.be.eventually.fulfilled;
})

  it("Buying transaction should fail. Accounts[1] is NOT on the whitelist",()=>{
  return expect(viddoSaleContract.sendTransaction({"from":accounts[1],"value":1})).to.be.eventually.rejected;
})



})


});
