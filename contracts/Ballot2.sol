//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

import "hardhat/console.sol";

contract Ballot2 {

    struct Proposal {
        string name;
        uint voteCount;
        bool exists;
    }

    struct Voter {
        bool voted;
        string proposal;
    }

    uint public closeDate;
    address public chairPerson;
    Proposal private currentWinner;

    mapping(address => Voter) public voters;
    mapping(string => Proposal) public proposals;
    mapping(address => bool) public voterAllowed;

    event Vote(address sender, string proposal, uint voteCount);
    event GiveVotePermission(address voter);
    event AddProposal(string name);

    constructor(uint _voteHours) {
        chairPerson = msg.sender;
        closeDate = block.timestamp + (_voteHours * 1 hours);
    }

    function giveVotePermission(address _voter) public {
        require(msg.sender == chairPerson, "only chairperson can give permission");
        require(!voterAllowed[_voter], "This voter can vote");
        require(!voters[_voter].voted, "Voter have voted already");
        voterAllowed[_voter] = true;

        emit GiveVotePermission(_voter);
    }

    function addProposal(string memory _name) public {
        require(msg.sender == chairPerson, "sender is not chairperson");
        proposals[_name].exists = true;

        emit AddProposal(_name);
    }

    function vote(string memory _name) public {
        require(voterAllowed[msg.sender], "no permission to vote");
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "already voted");
        require(proposals[_name].exists, "proposal not allowed");

        sender.proposal = _name;
        sender.voted = true;
        proposals[_name].voteCount++;  // update proposal vote count from sender

        if (proposals[_name].voteCount > currentWinner.voteCount) {
            currentWinner.name = _name;
            currentWinner.voteCount = proposals[_name].voteCount;
            require(
                currentWinner.voteCount == proposals[currentWinner.name].voteCount, 
                "Inconsistent winner value1"
            );
        }

        emit Vote(msg.sender, _name, proposals[_name].voteCount);
    }

    function winningProposal() public view returns (string memory) {
        require(
            currentWinner.voteCount == proposals[currentWinner.name].voteCount, 
            "Inconsistent winner value"
        );
        return currentWinner.name;
    }

}
