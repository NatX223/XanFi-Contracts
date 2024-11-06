const fs = require('fs'); // Import the file system module
const { ethers } = require('hardhat');

async function main() {
    const [signer] = await ethers.getSigners();

    const tokenAddresses = JSON.parse(fs.readFileSync('sepoliaTokenAddresses.json', 'utf-8'));
    const deploymentAddresses = JSON.parse(fs.readFileSync('sepoliaDeployedAddresses.json', 'utf-8'));

    // Find the tokens in the array (or any other token)
    const usdcToken = tokenAddresses.find(token => token.symbol === 'USDC');

    const usdcAddress = usdcToken ? usdcToken.address : null;

    if (!usdcAddress) {
        throw new Error("Token addresses not found.");
    }

    const Factory = await ethers.getContractFactory('IndexFactory', signer);

    const factory = await Factory.deploy(usdcAddress, deploymentAddresses.routerAddress);
    const factoryAddress = await factory.getAddress();

    deploymentAddresses.indexFactoryAddress = factoryAddress;

    console.log(`factoryAddress: ${factoryAddress}`);

    fs.writeFileSync('sepoliaDeployedAddresses.json', JSON.stringify(deploymentAddresses, null, 2));
    console.log('Addresses saved to deployedAddresses.json');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
