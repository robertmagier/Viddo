// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      gas: 914366353,
      network_id: '*', // Match any network id
      from:'0x2e6676612c69f4d72d2b3cdc8a7e234778f435b4'
    }
  }
}
