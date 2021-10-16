import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect, should } from "chai";
import { ethers } from "hardhat";

import { Ballot1 } from '../src/types/Ballot1';

let ballot1Factory;
let ballot1: Ballot1;
let accounts: SignerWithAddress[];

beforeEach( async() => {
  ballot1Factory = await ethers.getContractFactory("Ballot1");
  ballot1 = await ballot1Factory.deploy() as Ballot1;
  accounts = await ethers.getSigners(); 

  await ballot1.addProposal("Warodom");
  await ballot1.addProposal("Tanakorn");
  await ballot1.addProposal("Naratorn");
})

describe("Ballot1", function () {
  it("Vote should return Tanakorn", async () => {
    await ballot1.connect(accounts[1]).vote("Warodom");
    await ballot1.connect(accounts[2]).vote("Tanakorn");
    await ballot1.connect(accounts[3]).vote("Tanakorn");
    await ballot1.connect(accounts[4]).vote("Naratorn");

    expect(await ballot1.winningProposal()).to.equal("Tanakorn");
  })
});
