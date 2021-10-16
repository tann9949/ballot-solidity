//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

import "hardhat/console.sol";

contract Ballot3 {

    struct Proposal {
        bytes32 name;
        uint voteCount;
        bool exists;
    }

    struct Voter {
        bool voted;
        address delegate;
        uint weight;
        bytes32 proposal;
    }

    uint public closeDate;
    address public chairPerson;
    Proposal private currentWinner;

    mapping(address => Voter) public voters;
    mapping(bytes32 => Proposal) public proposals;

    event Vote(address sender, bytes32 proposal, uint voteCount);
    event GiveVotePermission(address voter);
    event AddProposal(bytes32 name);
    event Delegate(address sender, address delegator);

    constructor(uint _voteHours) {
        chairPerson = msg.sender;
        voters[chairPerson].weight = 1;  // give chairperson rights to vote by default
        closeDate = block.timestamp + (_voteHours * 1 hours);
    }

    function giveVotePermission(address _voter) public {
        require(msg.sender == chairPerson, "only chairperson can give permission");
        require(voters[_voter].weight == 0, "Voter already have permission to vote");
        require(!voters[_voter].voted, "Voter have voted already");
        voters[_voter].weight = 1;

        emit GiveVotePermission(_voter);
    }

    function delegate(address _delegateAddr) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted or delegated");
        require(msg.sender != _delegateAddr, "Self-delegation not allowed");

        // DELEGATE
        // voter that did not delagate to others 
        // will have default delagation address
        // which is address(0)
        while (voters[_delegateAddr].delegate != address(0)) {
            // iterate recursively until reach
            // wallet that not delagate to others
            _delegateAddr = voters[_delegateAddr].delegate;

            require(_delegateAddr != msg.sender, "delegation in loop");
        }
        
        sender.voted = true;
        sender.delegate = _delegateAddr;
        Voter storage delegate_ = voters[_delegateAddr];
        if (delegate_.voted) {
            proposals[delegate_.proposal].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }

        emit Delegate(msg.sender, _delegateAddr);
    }

    function addProposal(bytes32 _byteName) public {
        require(msg.sender == chairPerson, "sender is not chairperson");
        proposals[_byteName].exists = true;

        emit AddProposal(_byteName);
    }

    function vote(bytes32 _byteName) public {
        require(voters[msg.sender].weight > 0, "no permission to vote");
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "already voted");
        require(proposals[_byteName].exists, "proposal not allowed");

        sender.proposal = _byteName;
        sender.voted = true;
        proposals[_byteName].voteCount += sender.weight;  // update proposal vote count from sender

        if (proposals[_byteName].voteCount > currentWinner.voteCount) {
            currentWinner.name = _byteName;
            currentWinner.voteCount = proposals[_byteName].voteCount;
            require(
                currentWinner.voteCount == proposals[currentWinner.name].voteCount, 
                "Inconsistent winner value1"
            );
        }

        emit Vote(msg.sender, _byteName, proposals[_byteName].voteCount);
    }

    function winningProposal() public view returns (bytes32) {
        require(
            currentWinner.voteCount == proposals[currentWinner.name].voteCount, 
            "Inconsistent winner value"
        );
        return currentWinner.name;
    }

}
