const fs = require('fs'); // Import the file system module

async function main() {
    const [signer] = await ethers.getSigners();

    const tokens = [
        // Major Cryptocurrencies (Layer 1 Blockchains)
        { name: "Bitcoin", symbol: "BTC" },
        { name: "Ethereum", symbol: "ETH" },
        // { name: "Binance Coin", symbol: "BNB" },
        // { name: "Solana", symbol: "SOL" },
        // { name: "Avalanche", symbol: "AVAX" },
        // { name: "Cardano", symbol: "ADA" },
        // { name: "Near Protocol", symbol: "NEAR" },
      
        // DeFi Tokens
        { name: "Uniswap", symbol: "UNI" },
        { name: "Aave", symbol: "AAVE" },
        // { name: "Maker", symbol: "MKR" },
        // { name: "Synthetix", symbol: "SNX" },
        // { name: "Compound", symbol: "COMP" },
        // { name: "Curve DAO Token", symbol: "CRV" },
        // { name: "Yearn Finance", symbol: "YFI" },
      
        // Layer 2 Scaling Solutions
        { name: "Polygon", symbol: "MATIC" },
        { name: "Arbitrum", symbol: "ARB" },
        // { name: "Optimism", symbol: "OP" },
        // { name: "Loopring", symbol: "LRC" },
        // { name: "Immutable X", symbol: "IMX" },
      
        // Stablecoins
        // { name: "USD Coin", symbol: "USDC" },
        // { name: "DAI", symbol: "DAI" },
        // { name: "Tether", symbol: "USDT" },
        // { name: "Pax Dollar", symbol: "USDP" },
        // { name: "Binance USD", symbol: "BUSD" },
        // { name: "Frax", symbol: "FRAX" },
      
        // Gaming and NFT Tokens
        { name: "Axie Infinity", symbol: "AXS" },
        { name: "The Sandbox", symbol: "SAND" },
        // { name: "Decentraland", symbol: "MANA" },
        // { name: "Enjin Coin", symbol: "ENJ" },
        // { name: "Gala Games", symbol: "GALA" },
        // { name: "Illuvium", symbol: "ILV" },
        // { name: "Gods Unchained", symbol: "GODS" },
      
        // Interoperability and Cross-Chain Solutions
        { name: "Cosmos", symbol: "ATOM" },
        { name: "Polkadot", symbol: "DOT" },
        // { name: "Chainlink", symbol: "LINK" },
        // { name: "Quant", symbol: "QNT" },
        // { name: "Ren", symbol: "REN" },
        // { name: "Thorchain", symbol: "RUNE" },
        // { name: "Harmony", symbol: "ONE" }
    ];

    // Initialize an array to store token addresses
    let tokenAddresses = [];

    for (let i = 0; i < tokens.length; i++) {
        const Token = await ethers.getContractFactory('Token', signer);
        const token = await Token.deploy(tokens[i].name, tokens[i].symbol, "0x72De66bFDEf75AE89aD98a52A1524D3C5dB5fB24");
        const tokenAddress = await token.getAddress();
        
        // Push the token address to the array
        tokenAddresses.push({ name: tokens[i].name, symbol: tokens[i].symbol, address: tokenAddress });

        // Optionally, log the result
        console.log(`${tokens[i].name} deployed at: ${tokenAddress}`);
    }

    // Write the token addresses array to a file
    fs.writeFileSync('arbitrumTokenAddresses.json', JSON.stringify(tokenAddresses, null, 2));

    console.log('Token addresses saved to tokenAddresses.json');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
