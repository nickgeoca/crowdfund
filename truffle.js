module.exports = {
  build: {
    "index.html": "index.html",
    "web3.js": [
      'javascripts/web3.js'
    ],  
    "fundingHub.js": [
      "javascripts/_vendor/angular.js",
      "javascripts/fundingHubController.js"
    ],
    "app.css": [
      "stylesheets/app.css"
    ],
    "images/": "images/"
  },
  rpc: {
    host: "localhost",
    port: 8545
  }
};
