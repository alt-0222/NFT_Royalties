const HDWalletProvider = require("@truffle/hdwallet-provider");
const mnemonic = "whisper tornado bag easy chicken guard host hope address tobacco settle nice waste hire leave illegal trial surprise";

module.exports = {
  networks: {
    goerli: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://goerli.infura.io/v3/8d5dcdc78cbc41a6901880b0744d9c05");
      },
      network_id: 5
    },
    development: {
      host: "localhost",
      port: 8545,
      network_id: "1", 
      gas: 5000000
    }
  },
  compilers: {
    solc: {
      version: "^0.8.17",
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200      // Default: 200
        },
      }
    }
  }
};
