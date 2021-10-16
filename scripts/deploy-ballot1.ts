import fs from "fs";
import { ethers, artifacts } from "hardhat";
import { Ballot1 } from "../src/types/Ballot1";


async function main() {
    const ballot1Factory = await ethers.getContractFactory("ballotFactory");
    const ballot1: Ballot1 = await ballot1Factory.deploy() as Ballot1;

    await ballot1.deployed();
    console.log("Ballot1 Deployed to: ", ballot1.address);
    saveContract(ballot1);
}

function saveContract(ballot1: Ballot1) {
    const path = __dirname + '/../frontend/src/contracts';
    if (!fs.existsSync(path))
        fs.mkdirSync(path)

    fs.writeFileSync(
        path + '/address.json',
        JSON.stringify({ address: ballot1.address }, undefined, 2)
    );

    fs.writeFileSync(
        path + '/abi.json',
        JSON.stringify(artifacts.readArtifactSync('Ballot1'), undefined, 2)
    )
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    })