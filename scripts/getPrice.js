// Import ethers.js
const { ethers } = require("ethers");

// Set up your provider and contract information
const rpcurl = "https://arbitrum-sepolia.blockpi.network/v1/rpc/public";
const provider = new ethers.JsonRpcProvider(rpcurl);
const contractAddress = "0x7536498E96677a5B0d05a9897d58e5a6ae6eACbF";
const abi = [
    {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      }
];

// Create a contract instance
const contract = new ethers.Contract(contractAddress, abi, provider);

// Call the getPair function
async function fetchPair() {
    try {
        const price = await contract.totalSupply();
        console.log("price", price);
    } catch (error) {
        console.error("Error fetching price", error);
    }
}

fetchPair();
