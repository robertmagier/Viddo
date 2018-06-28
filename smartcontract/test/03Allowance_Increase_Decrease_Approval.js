var ViddoToken = artifacts.require("ViddoToken");

var chai = require("chai")
var chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
expect = chai.expect;

var viddoContract = 0;
var totalSupply = 0;
var owner = 0;

console.log();
contract("03. Testing Allowance and Approval Process + Increase and Decrease Approval. ", function(accounts) {
  describe("Deploy Viddo Token Smart Contract", function() {
    it("Catch an instance of Viddo Token Smart Contract", function() {
      return ViddoToken.new().then(function(instance) {
        viddoContract = instance
      });
    });
  });

  describe("Check initall allowance between owner and accounts[1] and other way.", function() {

    it("Owner's allowance to accounts[1] should be 0", function() {
      return viddoContract.allowance(accounts[0], accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(0)
      })
    });

    it("Accounts[1] allowance to accounts[0] should be 0", function() {
      return viddoContract.allowance(accounts[1], accounts[0]).then(function(res) {
        expect(parseInt(res)).to.be.equal(0)
      })
    });

  });

  describe(
    "Make allowance from accounts[1] as owner. Make transfer as accounts[1] to accounts[2] and check if it works.",
    function() {

      it("Owner approves spending 100 tokens by accounts[1]", function() {
        expect(viddoContract.approve(accounts[1], 100)).to.be.eventually.fulfilled
      });

      it("Accounts[1] allowance from accounts[0] should be 100", function() {
        return viddoContract.allowance(accounts[0], accounts[1]).then(function(res) {
          expect(parseInt(res)).to.be.equal(100)
        })
      });

      it("Accounts[1] transfer 50 tokens from accounts[0] to accounts[2] suceed.", function() {
        expect(viddoContract.transferFrom(accounts[0], accounts[2], 50, {
          "from": accounts[1]
        })).to.be.eventually.fulfilled;
      });

      it("Accounts[1] transfer 100 tokens from accounts[0] to accounts[2] fails. Not enough tokens approved.",
        function() {
          expect(viddoContract.transferFrom(accounts[0], accounts[2], 100, {
            "from": accounts[1]
          })).to.be.eventually.rejected;
        });

      it("Accounts[3] transfer 50 tokens from accounts[0] to accounts[2] fails.", function() {
        expect(viddoContract.transferFrom(accounts[0], accounts[2], 50, {
          "from": accounts[3]
        })).to.be.eventually.rejected;
      });

      it("Accounts[2] balance should be 50", function() {
        return viddoContract.balanceOf(accounts[2]).then(function(res) {
          expect(parseInt(res)).to.be.equal(50)
        })
      });

      it("Accounts[3] balance should be 0", function() {
        return viddoContract.balanceOf(accounts[3]).then(function(res) {
          expect(parseInt(res)).to.be.equal(0)
        })
      });

      it("Accounts[1] balance should be 0", function() {
        return viddoContract.balanceOf(accounts[1]).then(function(res) {
          expect(parseInt(res)).to.be.equal(0)
        })
      });

      it("Accounts[1] transfer 50 tokens from accounts[0] to accounts[1] succeed.", function() {
        expect(viddoContract.transferFrom(accounts[0], accounts[1], 50, {
          "from": accounts[1]
        })).to.be.eventually.fulfilled;
      });

      it("Accounts[1] balance should be 50", function() {
        return viddoContract.balanceOf(accounts[1]).then(function(res) {
          expect(parseInt(res)).to.be.equal(50)
        })
      });

      it("Accounts[1] allowance from accounts[]0] should be 0", function() {
        return viddoContract.allowance(accounts[0], accounts[1]).then(function(res) {
          expect(parseInt(res)).to.be.equal(0)
        })
      });

    });

  describe("Test increase and decrease approval.", function() {

    it("Owner approves spending 100 tokens by accounts[1]", function() {
      expect(viddoContract.approve(accounts[1], 100)).to.be.eventually.fulfilled
    });

    it("Accounts[1] allowance from accounts[0] should be 100", function() {
      return viddoContract.allowance(accounts[0], accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(100)
      })
    });

    it("Owner increase spending of  accounts[1] by 10", function() {
      expect(viddoContract.increaseApproval(accounts[1], 10)).to.be.eventually.fulfilled
    });

    it("Accounts[1] allowance from accounts[0] should be 110", function() {
      return viddoContract.allowance(accounts[0], accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(110)
      })
    });
    it("Owner decrease spending of accounts[1] by 20", function() {
      expect(viddoContract.decreaseApproval(accounts[1], 20)).to.be.eventually.fulfilled
    });

    it("Accounts[1] allowance from accounts[0] should be 90", function() {
      return viddoContract.allowance(accounts[0], accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(90)
      })
    });

    it("Owner decrease spending of accounts[1] by 300", function() {
      expect(viddoContract.decreaseApproval(accounts[1], 300)).to.be.eventually.fulfilled
    });

    it("Accounts[1] allowance from accounts[0] should be 0", function() {
      return viddoContract.allowance(accounts[0], accounts[1]).then(function(res) {
        expect(parseInt(res)).to.be.equal(0)
      })
    });
  });
})
