const { ethers } = require('hardhat');

async function main() {
    const [signer] = await ethers.getSigners();

    const router = "0x678c8faF8231F3219b5667098dd745d3E3a3BC2F";
    const factory = "0x557744B77910A3D4B94F97715F3556b646B53667";

    const DexHelper = await ethers.getContractFactory('DexHelper', signer);
    const dexhelper = await DexHelper.deploy(router, factory);

    const dexhelperAddress = await dexhelper.getAddress();
    console.log(dexhelperAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });