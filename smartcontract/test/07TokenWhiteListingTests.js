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

contract("07. Testing WhiteListing functionality", async (accounts)=>{
     describe("Deploy Viddo Token Smart Contract",    function () {
      it("Catch an instance of Viddo Token Smart Contract", function() {
      return ViddoToken.new().then(function(instance) {
        viddoTokenContract = instance
        console.log('    Viddo Token:'.blue,viddoTokenContract.address)
      });
    })
  });

   describe("Test WhiteListing functionality", () => {
    it("Add three first accounts to the whitelist and check if they are on the whitelist and if 2 next are not on th list.", () => {
      return viddoTokenContract.addToWhitelist(accounts[0]).then((res)=>{
        return viddoTokenContract.addToWhitelist(accounts[1]).then((res)=>{
          return viddoTokenContract.addToWhitelist(accounts[2]).then((res)=>{
            return viddoTokenContract.areWhiteListed(accounts).then((res)=>{
              expect(res[0]).to.be.true;
              expect(res[1]).to.be.true;
              expect(res[2]).to.be.true;
              expect(res[3]).to.be.false;
              expect(res[4]).to.be.false;
              })
            })
          })
        })
      })

    it("Remove three first from the whitelist. Using removeManyFromWhiteList", () => {
      return viddoTokenContract.removeManyFromWhitelist([accounts[0],accounts[1],accounts[2]]).then((res)=>{
        return viddoTokenContract.areWhiteListed(accounts).then((res)=>{
          expect(res[0]).to.be.false;
          expect(res[1]).to.be.false;
          expect(res[2]).to.be.false;
          expect(res[3]).to.be.false;
          expect(res[4]).to.be.false;
        })
      })
    })


    it("Try to transfer to not whielisted user.Must fail.", () => {
      return viddoTokenContract.removeManyFromWhitelist([accounts[0],accounts[1],accounts[2]]).then((res)=>{
          expect(viddoTokenContract.transfer(accounts[1],1)).to.be.rejected
      })
    })

    it("Add to whitelist and transfer to account. Must succeed. ", () => {
      return viddoTokenContract.addManyToWhitelist([accounts[1],accounts[2]]).then((res)=>{
          expect(viddoTokenContract.transfer(accounts[1],1)).to.be.fulfilled
      })
    })

    it("Add to whitelist and then remove and then transfer to account. Must fail. ", () => {
      return viddoTokenContract.addToWhitelist(accounts[1]).then((res)=>{
        return viddoTokenContract.removeFromWhitelist(accounts[1]).then((res)=>{
          expect(viddoTokenContract.transfer(accounts[1],1)).to.be.rejected
        })
      })
    })

  })

});
