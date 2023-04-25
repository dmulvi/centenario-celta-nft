const hre = require("hardhat");

async function main() {
  const crossmintAddress = "0xDa30ee0788276c093e686780C25f6C9431027234"; // mumbai
  //const crossmintAddress = "0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002"; // polygon mainnet

  const CentenarioCeltaNFT = await hre.ethers.getContractFactory("CentenarioCelta");
  const CentenarioCelta = await CentenarioCeltaNFT.deploy(crossmintAddress);

  await CentenarioCelta.deployed();

  console.log("CentenarioCelta deployed to:", CentenarioCelta.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
