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

     describe("Generate New Receiver. And check Receiver flow",   async () => {
      it("Check if receiver is marked as receiver", () => {
        return viddoTokenContract.GenerateReceiver.sendTransaction().then((res)=>{
          return viddoTokenContract.lastReceiver().then((res2)=>{
            return viddoTokenContract.IsReceiver(res2).then((res3)=>{
              expect(res3).to.be.true;
            })
          })
        })
    })
      it("Check if receiver is marked as not confirmed without token transfer", () => {
        return viddoTokenContract.GenerateReceiver.sendTransaction().then((res)=>{
          return viddoTokenContract.lastReceiver().then((res2)=>{
            return viddoTokenContract.IsReceiverConfirmed(res2).then((res3)=>{
              expect(res3).to.be.false;
            })
          })
        })
    })

      it("Check if receiver is marked as confirmed after token transfer", () => {
        return viddoTokenContract.GenerateReceiver.sendTransaction().then((res)=>{
          return viddoTokenContract.lastReceiver().then((res2)=>{
            return viddoTokenContract.transfer(res2,1).then((res)=>{
              return viddoTokenContract.IsReceiverConfirmed(res2).then((res3)=>{
                expect(res3).to.be.true;
              })
            })
          })
        })
    })

      it("Check if receiver use transfered amount of tokens. ", () => {

        return viddoTokenContract.balanceOf.call(accounts[0]).then((res)=>{
          var balance = parseInt(res)
          return viddoTokenContract.GenerateReceiver.sendTransaction().then((res)=>{
            return viddoTokenContract.lastReceiver().then((res)=>{
              return viddoTokenContract.transfer(res,balance).then((res)=>{
                return viddoTokenContract.balanceOf(accounts[0]).then((res)=>{
                  expect(parseInt(res)).to.be.equal(0);
                })
              })
            })
          })
        })
    })



  });


});
