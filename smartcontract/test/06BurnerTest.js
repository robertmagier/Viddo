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
contract("06. Testing Burner Functionality",   async (accounts)=>{
     describe("Deploy Viddo Token Smart Contract",    function () {
      it("Catch an instance of Viddo Token Smart Contract", function() {
      return ViddoToken.new().then(function(instance) {
        viddoTokenContract = instance
        console.log('    Viddo Token:'.blue,viddoTokenContract.address)

      });
    })
  });

   describe("Test Burner functionality", () => {
    it("Set new Burner and check if it was set. ", () => {
      return viddoTokenContract.SetBurner(accounts[1]).then((res)=>{
        return viddoTokenContract.burner().then((res)=>{
          expect(res).to.be.equal(accounts[1]);
        })
      })
    })
    it("Check if only Burner can call BurnForProAccount function", () => {
      return viddoTokenContract.SetBurner(accounts[0]).then((res)=>{
        expect( viddoTokenContract.BurnForProAccount()).to.be.fulfilled;
      })
    })
    it("Check if only Burner can call BurnForProAccount function.Non-burner user is rejected", () => {
      return viddoTokenContract.SetBurner(accounts[1]).then((res)=>{
        expect( viddoTokenContract.BurnForProAccount()).to.be.rejected;
      })
    })
    it("Check if BurnForProAccount function burns one token", () => {
      return viddoTokenContract.balanceOf(accounts[0]).then((res)=>{
        var balance = parseInt(res)
        return viddoTokenContract.SetBurner(accounts[0]).then((res)=>{
          return viddoTokenContract.BurnForProAccount().then((res)=>{
            return viddoTokenContract.balanceOf(accounts[0]).then((res)=>{
              expect(parseInt(res)).to.be.equal(balance-1)
            })
          })
        })
      })
    })
    it("Check if BuyProAccount function burns one token", () => {
      return viddoTokenContract.balanceOf(accounts[0]).then((res)=>{
        var balance = parseInt(res)
        return viddoTokenContract.GenerateReceiver.sendTransaction().then((res)=>{
          return viddoTokenContract.lastReceiver().then((receiver)=>{
            return viddoTokenContract.SetBurner(accounts[0]).then((res)=>{
              return viddoTokenContract.BuyProAccount(receiver).then((res)=>{
                return viddoTokenContract.balanceOf(accounts[0]).then((res)=>{
                  expect(parseInt(res)).to.be.equal(balance-1)
                })
              })
            })
          })
        })
      })
    })

    it("Check if receiver is marked as confirmed after BuyProAccount function is called by Burner", () => {
      return viddoTokenContract.SetBurner(accounts[0]).then((res)=>{
        return viddoTokenContract.GenerateReceiver.sendTransaction().then((res)=>{
          return viddoTokenContract.lastReceiver().then((res2)=>{
            // console.log("Last receiver:",res2)
            return viddoTokenContract.BuyProAccount(res2).then((res)=>{
              return viddoTokenContract.IsReceiverConfirmed(res2).then((res3)=>{
                expect(res3).to.be.true;
              })
            })
          })
        })
      })
  })


  });


});
