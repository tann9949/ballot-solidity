import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect, should } from "chai";
import { ethers } from "hardhat";

import { Ballot3 } from '../src/types/Ballot3';

let ballot3Factory;
let ballot3: Ballot3;
let accounts: SignerWithAddress[];

beforeEach( async() => {
  ballot3Factory = await ethers.getContractFactory("Ballot3");
  ballot3 = await ballot3Factory.deploy(1) as Ballot3;
  accounts = await ethers.getSigners(); 

  await ballot3.addProposal(ethers.utils.formatBytes32String("Warodom"));
  await ballot3.addProposal(ethers.utils.formatBytes32String("Tanakorn"));
  await ballot3.addProposal(ethers.utils.formatBytes32String("Naratorn"));
})

describe("Ballot3", function () {
  it("Vote should return Tanakorn", async () => {
    for (let i = 1; i < 10; i ++) {
      await ballot3.connect(accounts[0]).giveVotePermission(accounts[i].address);
    }
    
    // delegate 4 => 6 => 5 => 7
    await ballot3.connect(accounts[4]).delegate(accounts[6].address);
    expect((await ballot3.voters(accounts[6].address)).weight.toString()).to.equal("2");
    await ballot3.connect(accounts[6]).delegate(accounts[5].address);
    expect(+ (await ballot3.voters(accounts[5].address)).weight).to.equal(3);
    await ballot3.connect(accounts[5]).delegate(accounts[7].address);
    expect(+ (await ballot3.voters(accounts[7].address)).weight).to.equal(4);
    
    // delegate 8 => 4, account 7 should got 5 weight
    await ballot3.connect(accounts[8]).delegate(accounts[4].address);
    expect(+ (await ballot3.voters(accounts[7].address)).weight).to.equal(5);
    
    await ballot3.connect(accounts[2]).vote(ethers.utils.formatBytes32String("Naratorn"));
    await ballot3.connect(accounts[3]).vote(ethers.utils.formatBytes32String("Warodom"));
    await ballot3.connect(accounts[7]).vote(ethers.utils.formatBytes32String("Tanakorn"));
    expect(+ (await ballot3.proposals(ethers.utils.formatBytes32String("Naratorn"))).voteCount).to.equal(1);
    expect(+ (await ballot3.proposals(ethers.utils.formatBytes32String("Warodom"))).voteCount).to.equal(1);
    expect(+ (await ballot3.proposals(ethers.utils.formatBytes32String("Tanakorn"))).voteCount).to.equal(5);

    expect(ethers.utils.parseBytes32String(await ballot3.winningProposal())).to.equal("Tanakorn");
  })
});
