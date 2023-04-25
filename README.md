# Centenario Celta NFT Project

This is a sample NFT project that enables using the same smart contract with Crossmint Payments and Crossmint Minting 
API concurrently. 

### Initial setup/installation
* clone this repository to your local machine: `git clone git@github.com:dmulvi/centenario-celta-nft.git`
* move into directory: `cd centenario-celta-nft`
* install dependencies: `yarn install`

### The NFT Contract
* Is NOT using ERC721URIStorage on purpose. This is because the project is using the same metadata for every NFT. To simplify the way this works the `tokenURI` function is overridden and always returns the same value, which points to the metadata on IPFS. This baseUri can also be updated by calling the `setUri` function from the deployer address. You can see a sample of the metadata in the root directory of this repo: `metadata.json`. 
* The price can be updated with the `setPrice` function. 

### Setting up the environment to deploy
* copy the `sample.env` file to `.env`
* fill in the values in this .env file to be able to deploy contract

### Deploy the contract
* mainnet vs mumbai - check the scripts/deploy.js to uncomment/comment the correct crossmintAddress value
* to deploy the contract: `npx hardhat run scripts/deploy.js --network mumbai`
* wait about 30 seconds, then verify: `npx hardhat verify 0x123_address_from_prev_command 0xabc_crossmint_treasury`
    * the last value in prev command must match the crossmint address passed in the `deploy.js` script

### Register the contract with Crossmint
* login to the staging or production crossmint console depending on whether you used mumbai or mainnet
* register the `crossmint` function (it will be selected automatically after you add the contract address)
* share the `clientId` from previous step
* create an API Key with the `nfts.mint` scope
* share the `projectId` associated with the new key
* we will manually configure your api key to use the custom contract


* notes about calling the API with an empty `contractArguments` array