module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*"
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 999
    }
  }
};