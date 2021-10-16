import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect, should } from "chai";
import { ethers } from "hardhat";

import { Ballot2 } from '../src/types/Ballot2';

let ballot2Factory;
let ballot2: Ballot2;
let accounts: SignerWithAddress[];

beforeEach( async() => {
  ballot2Factory = await ethers.getContractFactory("Ballot2");
  ballot2 = await ballot2Factory.deploy(1) as Ballot2;
  accounts = await ethers.getSigners(); 

  await ballot2.addProposal("Warodom");
  await ballot2.addProposal("Tanakorn");
  await ballot2.addProposal("Naratorn");

  await ballot2.connect(accounts[0]).giveVotePermission(accounts[0].address);
  await ballot2.connect(accounts[0]).vote("Naratorn");
})

describe("Ballot2", function () {
  it("Vote should return Tanakorn", async () => {
    for (let i = 1; i < 5; i ++) {
      await ballot2.connect(accounts[0]).giveVotePermission(accounts[i].address);
    }

    await ballot2.connect(accounts[1]).vote("Warodom");
    await ballot2.connect(accounts[2]).vote("Tanakorn");
    await ballot2.connect(accounts[3]).vote("Tanakorn");
    await ballot2.connect(accounts[4]).vote("Naratorn");

    // still tanakorn because Tanakorn reqch 
    // max first according to smart contract logic
    expect(await ballot2.winningProposal()).to.equal("Tanakorn");
  })
});
