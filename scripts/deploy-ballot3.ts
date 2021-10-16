import fs from "fs";
import { ethers, artifacts } from "hardhat";
import { Ballot3 } from "../src/types/Ballot3";


async function main() {
    const ballot3Factory = await ethers.getContractFactory("ballotFactory");
    const ballot3: Ballot3 = await ballot3Factory.deploy() as Ballot3;

    await ballot3.deployed();
    console.log("Ballot3 Deployed to: ", ballot3.address);
    saveContract(ballot3);
}

function saveContract(ballot3: Ballot3) {
    const path = __dirname + '/../frontend/src/contracts';
    if (!fs.existsSync(path))
        fs.mkdirSync(path)

    fs.writeFileSync(
        path + '/address.json',
        JSON.stringify({ address: ballot3.address }, undefined, 2)
    );

    fs.writeFileSync(
        path + '/abi.json',
        JSON.stringify(artifacts.readArtifactSync('Ballot3'), undefined, 2)
    )
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    })