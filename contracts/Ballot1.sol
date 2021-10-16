//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

import "hardhat/console.sol";

contract Ballot1 {

    struct Proposal {
        string name;
        uint voteCount;
    }

    struct Voter {
        bool voted;
        string proposal;
    }

    address public chairPerson;
    Proposal private currentWinner;

    mapping(address => Voter) public voters;
    mapping(string => uint) public proposals;
    mapping(string => bool) public proposalExists;

    constructor() {
        chairPerson = msg.sender;
    }

    function addProposal(string memory _name) public {
        require(msg.sender == chairPerson, "sender is not owner");
        proposalExists[_name] = true;
    }

    function vote(string memory _name) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "already voted");
        require(proposalExists[_name], "proposal not allowed");

        sender.proposal = _name;
        sender.voted = true;
        proposals[_name]++;  // update proposal vote count from sender

        if (proposals[_name] > currentWinner.voteCount) {
            currentWinner.name = _name;
            currentWinner.voteCount = proposals[_name];
            require(
                currentWinner.voteCount == proposals[currentWinner.name], 
                "Inconsistent winner value1"
            );
        }
    }

    function winningProposal() public view returns (string memory) {
        require(currentWinner.voteCount == proposals[currentWinner.name], "Inconsistent winner value");
        return currentWinner.name;
    }

}
