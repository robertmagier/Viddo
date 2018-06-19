var ViddoToken = artifacts.require("ViddoToken");

var chai = require("chai")
var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
expect = chai.expect;

var viddoContract = 0;
var totalSupply = 0;

contract("Test Viddo Token Contract", function(accounts) {
  describe("Deploy Viddo Token Smart Contract", function() {
    it("Catch an instance of Viddo Token Smart Contract", function() {
      return ViddoToken.new().then(function(instance) {
        // console.log(instance.address)
        viddoContract = instance
      });
    });
  });

  describe("Check contract variables", function() {

    it("Contract name is VIDDOToken", function() {
      return viddoContract.name().then(function(res) {
        expect(res.toString()).to.be.equal("VIDDOToken")
      })
    });

    it("Total Supply is equal to 100 * 10**6 (100 000 000)", function() {
      return viddoContract.totalSupply().then(function(res) {
        totalSupply = parseInt(res)
        expect(totalSupply).to.be.equal(100 * 10 * * 6)
      })
    });

    it("Contract symbol is VDT", function() {
      return viddoContract.symbol().then(function(res) {
        expect(res.toString()).to.be.equal("VDT")
      })
    });

    it("Token has 0 decimals", function() {
      return viddoContract.decimals().then(function(res) {
        expect(parseInt(res)).to.be.equal(0)
      })
    });

    it("Contract owner is set to contract creator (accounts[0])", function() {
      return viddoContract.owner().then(function(res) {
        expect(res.toString()).to.be.equal(accounts[0].toString())
      })
    });

    it("Token creator (accounts[0]) owns all tokens - totalSupply.", function() {
      return viddoContract.balanceOf(accounts[0]).then(function(res) {
        expect(parseInt(res)).to.be.equal(totalSupply)
      })
    });

    it("Another account (accounts[1]) doesn't own any tokens ( zero )", function() {
      return viddoContract.balanceOf(accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(0)
      })
    });

  });

  describe("Check token transfer and balance function", function() {

    it("Transfer 50 000 000 tokens from owner to another account (accounts[1])", function() {
      return viddoContract.transfer(accounts[1], 50 * 10 * * 6).then(function(res) {
        return viddoContract.balanceOf(accounts[1]).then(function(res) {
          expect(parseInt(res)).to.be.equal(50 * 10 * * 6)
        })
      })
    })

    it(
      "Transfer 60 000 000 tokens from owner to another account (accounts[1]).Too many tokens. Transaction should fail.Ballance of accounts[0] (owner) should be unchanged",
      function() {
        expect(viddoContract.transfer(accounts[1], 60 * 10 * * 6)).to.be.eventually.rejected;
      })

    it("Owner's balance should be 50 000 000", function() {
      return viddoContract.balanceOf(accounts[0]).then(function(res) {
        expect(parseInt(res)).to.be.equal(50 * 10 * * 6)
      })
    })

    it("accounts[1] balance should be also 50 000 000", function() {
      return viddoContract.balanceOf(accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(50 * 10 * * 6)
      })
    })

    it("Transfer 15 000 000 tokens from accounts[1] to accounts[0]", function() {
      expect(viddoContract.transfer(accounts[0], 15 * 10 * * 6, {
        "from": accounts[1]
      })).to.be.eventually.fulfilled;
    })

    it("accounts[0] balance should be 65 000 000", function() {
      return viddoContract.balanceOf(accounts[0]).then(function(res) {
        expect(parseInt(res)).to.be.equal(65 * 10 * * 6)
      })
    })

    it("accounts[1] balance should be also 35 000 000", function() {
      return viddoContract.balanceOf(accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(35 * 10 * * 6)
      })
    })

  })
})
