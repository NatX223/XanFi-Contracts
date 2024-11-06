const fs = require('fs'); // Import the file system module

async function main() {
    const [signer] = await ethers.getSigners();

    const name = "USD Coin";
    const symbol = "USDC"
    const Token = await ethers.getContractFactory('Token', signer);
    const token = await Token.deploy(name, symbol, "0x72De66bFDEf75AE89aD98a52A1524D3C5dB5fB24");
    const tokenAddress = await token.getAddress();

    const mintAmount = ethers.parseEther("1000000000000");
    
    // Optionally, log the result
    console.log(`${name} deployed at: ${tokenAddress}`);
    await token.mint("0x72De66bFDEf75AE89aD98a52A1524D3C5dB5fB24", mintAmount);

    console.log('Token minted');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
