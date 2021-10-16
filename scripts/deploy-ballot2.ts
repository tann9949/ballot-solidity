import fs from "fs";
import { ethers, artifacts } from "hardhat";
import { Ballot2 } from "../src/types/Ballot2";


async function main() {
    const ballot2Factory = await ethers.getContractFactory("ballotFactory");
    const ballot2: Ballot2 = await ballot2Factory.deploy() as Ballot2;

    await ballot2.deployed();
    console.log("Ballot2 Deployed to: ", ballot2.address);
    saveContract(ballot2);
}

function saveContract(ballot2: Ballot2) {
    const path = __dirname + '/../frontend/src/contracts';
    if (!fs.existsSync(path))
        fs.mkdirSync(path)

    fs.writeFileSync(
        path + '/address.json',
        JSON.stringify({ address: ballot2.address }, undefined, 2)
    );

    fs.writeFileSync(
        path + '/abi.json',
        JSON.stringify(artifacts.readArtifactSync('Ballot2'), undefined, 2)
    )
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    })