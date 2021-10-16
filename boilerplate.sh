#!/bin/bash

# install dotenv and init dotenv
npm i dotenv
echo -ne "SEED=''\nRPC_URL=''" > .env.example

# init hardhat
npx hardhat || { echo "Fail initializing hardhat with command `npx hardhat`"; exit 1; }

# init vite
npm init vite@latest frontend -- --template react-ts || { echo "Fail initializing vite with command `npm init vite@latest frontend -- --template react`"; exit 1; }
cd frontend && npm i && cd ..

npm i --save-dev ts-node typescript chai @types/node @types/mocha @types/chai @ethersproject/providers

cat << EOF > frontend/src/vite-env.d.ts
/// <reference types="vite/client" />

interface Window {
    ethereum: any
}
EOF

# init typechain deps
npm install --save-dev typechain \
  @typechain/hardhat \
  @typechain/ethers-v5 --force

#### convert JS files to TS convention ####
mv hardhat.config.js hardhat.config.ts
mv scripts/sample-script.js scripts/sample-script.ts
mv test/sample-test.js test/sample-test.ts

# change hardhat.config.ts to es2018
cat << EOF > hardhat.config.ts
import { config } from "dotenv";
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'

config()

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const userConfig: HardhatUserConfig = {
  solidity: "0.8.4",
  networks: {
    // rinkeby: {
    //   url: process.env.RPC_URL,
    //   accounts: { mnemonic: process.env.SEED },
    //   // accounts: [privateKey]
    // }
    hardhat: {
      chainId: 1337  // metamask localhost use 1337
    }
  },
  typechain: {
    outDir: 'src/types',
    target: 'ethers-v5',
    alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    externalArtifacts: ['externalArtifacts/*.json'], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
  },
};

export default userConfig;
EOF
# init tsconfig.json
cat << EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "es2018",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "dist"
  },
  "include": ["./scripts", "./test"],
  "files": ["./hardhat.config.ts"]
}
EOF
# fix deploy script
cat << EOF > scripts/sample-script.ts

import fs from "fs";
import { ethers, artifacts } from "hardhat";
import { Greeter } from "../src/types/Greeter";

async function main() {
  const Greeter = await ethers.getContractFactory("Greeter");
  const greeter: Greeter = await Greeter.deploy("Hello, Hardhat!") as Greeter;

  await greeter.deployed();
  console.log("Greeter deployed to:", greeter.address);
  saveContract(greeter);
}

function saveContract(greeter: Greeter) {
  const path = __dirname + '/../frontend/src/contracts';  // get Contracts path
  if ( !fs.existsSync(path) )  // make sure dir Contracts exists
    fs.mkdirSync(path)

  fs.writeFileSync(path + '/address.json',  // save address
    JSON.stringify( { address: greeter.address }, undefined, 2)
  )

  fs.writeFileSync(path + '/abi.json',  // save abi
    JSON.stringify( artifacts.readArtifactSync('Greeter'), undefined, 2)
  )
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
EOF
# change test script
cat << EOF > test/sample-test.ts
import { expect } from "chai";
import { ethers } from "hardhat";

import {Greeter} from '../src/types/Greeter';

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter: Greeter = await Greeter.deploy("Hello, world!") as Greeter;
    // await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
EOF

#### Test changed scripts ####

# complie contracts
npx hardhat compile || { echo "Fail compiling Greeting contract with command `npx hardhat compile`"; exit 1; }
# run deploy
npx hardhat run scripts/sample-script.ts || { echo "Fail deploying Greeting contract with command `npx hardhat run scripts/sample-script.ts`"; exit 1; }
# run test
npx hardhat test

echo "Building boilerplate finished!"