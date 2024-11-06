const fs = require('fs'); // Import the file system module
const { ethers } = require('hardhat');

async function main() {
    const [signer] = await ethers.getSigners();

    const tokenAddresses = JSON.parse(fs.readFileSync('sepoliaTokenAddresses.json', 'utf-8'));

    // Find the tokens in the array (or any other token)
    const usdcToken = tokenAddresses.find(token => token.symbol === 'USDC');
    const btcToken = tokenAddresses.find(token => token.symbol === 'BTC');
    const ethToken = tokenAddresses.find(token => token.symbol === 'ETH');

    const usdcAddress = usdcToken ? usdcToken.address : null;
    const btcAddress = usdcToken ? btcToken.address : null;
    const ethAddress = usdcToken ? ethToken.address : null;

    if (!usdcAddress || !btcAddress || !ethAddress) {
        throw new Error("Token addresses not found.");
    }

    const Factory = await ethers.getContractFactory('Factory', signer);
    const Router = await ethers.getContractFactory('Router', signer);

    const factory = await Factory.deploy();
    const factoryAddress = await factory.getAddress();

    const router = await Router.deploy(factoryAddress, usdcAddress);
    const routerAddress = await router.getAddress();

    console.log(`factoryAddress: ${factoryAddress}, routerAddress: ${routerAddress}`);

    // Write the addresses to a file
    const addresses = {
        factoryAddress: factoryAddress,
        routerAddress: routerAddress,
    };

    fs.writeFileSync('sepoliaDeployedAddresses.json', JSON.stringify(addresses, null, 2));
    console.log('Addresses saved to deployedAddresses.json');

    // Create the pairs
    await factory.createPair(usdcAddress, btcAddress);
    await factory.createPair(usdcAddress, ethAddress);
    console.log("Pairs created");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
