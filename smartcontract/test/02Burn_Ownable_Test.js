var ViddoToken = artifacts.require("ViddoToken");

var chai = require("chai")
var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
expect = chai.expect;

var viddoContract = 0;
var totalSupply = 0;
var owner = 0;

console.log();
contract("Testing Burning and Ownable functionality",function(accounts){
  describe("Deploy Viddo Token Smart Contract",function(){
    it("Catch an instance of Viddo Token Smart Contract",function(){
      return ViddoToken.new().then(function(instance){
        viddoContract = instance
      });
    });
  });

  describe("Check contract variables",function(){

    it("Total Supply is equal to 100 * 10**6 (100 000 000)",function(){
      return viddoContract.totalSupply().then(function(res){
        totalSupply = parseInt(res)
        expect(totalSupply).to.be.equal(100 * 10 ** 6)
      })
    });

    it("Contract owner is set to contract creator (accounts[0])",function(){
      return viddoContract.owner().then(function(res){
        owner = res.toString()
        expect(owner).to.be.equal(accounts[0].toString())
      })
    });


  });

  describe("Check token burn function",function(){

    it("Transfer 50 000 000 tokens from owner to another account (accounts[1])",function(){
      return viddoContract.transfer(accounts[1],50*10**6).then(function(res){
        return viddoContract.balanceOf(accounts[1]).then(function(res){
          expect(parseInt(res)).to.be.equal(50*10**6)
        })
      })
    })

    it("Owner's balance should be 50 000 000",function(){
      return viddoContract.balanceOf(accounts[0]).then(function(res){
        expect(parseInt(res)).to.be.equal(50*10**6)
      })
    })

    it("accounts[1] balance should be also 50 000 000",function(){
      return viddoContract.balanceOf(accounts[1]).then(function(res){
        expect(parseInt(res)).to.be.equal(50*10**6)
      })
    })

    it("Burn all 50 000 000 tokens from owner account",function(){
      expect(viddoContract.burn(50*10**6)).to.be.eventually.fulfilled;
    })

    it("Check if totalSupply is equal to initall value minus 50 000 000",function(){
      return viddoContract.totalSupply().then(function(res){
        expect(parseInt(res)).to.be.equal(totalSupply-50*10**6)
      })
    })

    it("Check if owner balance is equal zero (0)",function(){
      return viddoContract.balanceOf(accounts[0]).then(function(res){
        expect(parseInt(res)).to.be.equal(0)
      })
    })

    it("Check if owner can't burn more tokens than it owns",function(){
      expect(viddoContract.burn(1)).to.be.eventually.rejected;
    })

    it("Check if owner balance is equal zero (0)",function(){
      return viddoContract.balanceOf(accounts[0]).then(function(res){
        expect(parseInt(res)).to.be.equal(0)
      })
    })

    it("Burn account[1] 1 token.",function(){
      expect(viddoContract.burn(1,{"from":accounts[1]})).to.be.eventually.fulfilled;
    })

    it("Check if accounts[1] balance is minus 1",function(){
      return viddoContract.balanceOf(accounts[1]).then(function(res){
        expect(parseInt(res)).to.be.equal(50*10**6-1)
      })
    })

    it("Check if accounts[1] can't burn more tokens than it owns",function(){
      expect(viddoContract.burn(50*10**6,{"from":accounts[1]})).to.be.eventually.rejected;
    })

    it("Check if accounts[1] can't burn negative tokens amount",function(){
      expect(viddoContract.burn(-1,{"from":accounts[1]})).to.be.eventually.rejected;
    })

    it("Accounts[1] balance should stay the same.",function(){
      return viddoContract.balanceOf(accounts[1]).then(function(res){
        expect(parseInt(res)).to.be.equal(50*10**6-1)
      })
    })

    it("Total Supply should be initial value minus 50 000 000 and minus 1.",function(){
      return viddoContract.totalSupply().then(function(res){
        expect(parseInt(res)).to.be.equal(totalSupply - 50*10**6-1)
      })
    })



})
})
