// Import ethers.js
const { ethers } = require("ethers");

// Set up your provider and contract information
const rpcurl = "https://arbitrum-sepolia.blockpi.network/v1/rpc/public";
const provider = new ethers.JsonRpcProvider(rpcurl);
const contractAddress = "0xfAE79F8782dD49c379676AE9F928bE3C444014E3";
const abi = [
    {
        "constant": true,
        "inputs": [
            { "name": "", "type": "address" },
            { "name": "", "type": "address" }
        ],
        "name": "getPair",
        "outputs": [
            { "name": "", "type": "address" }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    }
];

// Create a contract instance
const contract = new ethers.Contract(contractAddress, abi, provider);

// Addresses to use for the mapping lookup
const usdc = "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d";
const token = "0xa15248359B1dB89eBa482c862E861f3e01A125B4";

// Call the getPair function
async function fetchPair() {
    try {
        const pairAddress = await contract.getPair(usdc, token);
        console.log("Pair Address:", pairAddress);
    } catch (error) {
        console.error("Error fetching pair:", error);
    }
}

fetchPair();
