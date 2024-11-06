const fs = require('fs'); // Import the file system module
const { ethers } = require('hardhat');

async function main() {
    const [signer] = await ethers.getSigners();

    const tokenAddresses = JSON.parse(fs.readFileSync('arbitrumTokenAddresses.json', 'utf-8'));
    const deployedAddresses = JSON.parse(fs.readFileSync('arbitrumDeployedAddresses.json', 'utf-8'));

    // Find the tokens in the array (or any other token)
    const usdcToken = tokenAddresses.find(token => token.symbol === 'USDC');
    const Factory = await ethers.getContractFactory('Factory', signer);
    const factory = Factory.attach(deployedAddresses.factoryAddress);
    const Router = await ethers.getContractFactory('Router', signer);
    const router = Router.attach(deployedAddresses.routerAddress);
    const routerAddress = deployedAddresses.routerAddress;
    const Token = await ethers.getContractFactory('Token', signer);
    const usdcAmount = 10 * (10 ** 6);
    const tokenAmount = ethers.parseEther("1");
    const usdc = Token.attach(usdcToken.address);
    for (let i = 3; i < 8; i++) {
      const tokenAddress = tokenAddresses[i].address;
      
      const token = Token.attach(tokenAddress);
      await usdc.approve(routerAddress, usdcAmount);
      await token.approve(routerAddress, tokenAmount);
      
      // Create the pairs
      await factory.createPair(usdcToken.address, tokenAddress);
      console.log("approved");
  
      await router.addLiquidity(usdcAmount, tokenAmount, usdcToken.address, tokenAddress);
      console.log("Pairs created");
    }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
