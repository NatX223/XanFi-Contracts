const { utils, Wallet, ethers } = require("ethers")

const tokenAbi = [
    {
        "inputs": [
          {
            "internalType": "address",
            "name": "spender",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
          }
        ],
        "name": "approve",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      }
]

const routerAbi = [
    {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "amountA",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "amountB",
            "type": "uint256"
          },
          {
            "internalType": "contract IERC20",
            "name": "tokenA",
            "type": "address"
          },
          {
            "internalType": "contract IERC20",
            "name": "tokenB",
            "type": "address"
          }
        ],
        "name": "addLiquidity",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "receiver",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "amountIn",
            "type": "uint256"
          },
          {
            "internalType": "contract IERC20",
            "name": "tokenIn",
            "type": "address"
          },
          {
            "internalType": "contract IERC20",
            "name": "tokenOut",
            "type": "address"
          }
        ],
        "name": "swapExactTokens",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
]


const routerAddress = "0xED5DE52232a49b9a0A154bf3a956c1c06a388791";
// const USDCAddress = "0x516cEE439aAD73819fA34b64154D2A73f1A1a680";
// const WAVAXAddress = "0x6e1d4c8E33545B83fFd6D4F2d69FbEB42fB8B4D5";
// const GMXAddress = "0x40676EDC9781304357f7219667d7c35181b6cE86";

// const WAVAXUSDTAmount = ethers.parseEther("2300");
// const WAVAXAmount = ethers.parseEther("100");
// const GMXUSDTAmount = ethers.parseEther("2500");
// const GMXAmount = ethers.parseEther("100");

// const dollarAmounts = {
//   WAVAXUSDTAmount,
//   GMXUSDTAmount,
//   SUSHIUSDTAmount,
//   TRUUSDTAmount
// }

// const tokenAmounts = [
//   WAVAXAmount,
//   GMXAmount,
//   SUSHIAmount,
//   TRUAmount
// ]

// const Addresses = [
//   WAVAXAddress,
//   GMXAddress,
//   SUSHIAddress,
//   TRUAddress
// ]

async function main() {
    const rpcurl = "https://arbitrum-sepolia.blockpi.network/v1/rpc/public";

    const privateKey = "d56cefa29a2bb8127184dc026147e95293b511850ad2f68f97de8cf1b13cabe8";
    const wallet = new Wallet(privateKey);

    const provider = new ethers.JsonRpcProvider(rpcurl);

    const signer = wallet.connect(provider);  
    
    const usdcAmount = 5 * (10 ** 6);
    const wbtcAmount = ethers.parseEther("0.5");

    const usdc = new ethers.Contract("0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d", tokenAbi, signer);
    const wbtc = new ethers.Contract("0xa4480565af9a87770FDa24c6eDE28D00E7881b3a", tokenAbi, signer);

    await usdc.approve(routerAddress, usdcAmount);
    await wbtc.approve(routerAddress, wbtcAmount);

    console.log("approved");

    const router = new ethers.Contract(routerAddress, routerAbi, signer);
    await router.addLiquidity(usdcAmount, wbtcAmount, "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d", "0xa4480565af9a87770FDa24c6eDE28D00E7881b3a");
    // await router.swapExactTokens(signer.address, usdcAmount, "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d", "0xa15248359B1dB89eBa482c862E861f3e01A125B4");
    console.log("added");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });



