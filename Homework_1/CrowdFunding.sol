// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.17;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";

contract CrowdFunding {
    uint public fundingGoal;
    uint private funding;
    State public currentState;
    address owner;
    uint index;
    mapping (address => Contributor) contributors;
    SponsorFunding sponsorFunding;
    DistributeFunding distributeFunding;

    event BeforeBalanceSent(address, uint, uint);
    event AfterBalanceSent(uint);

    struct Contributor {
        uint id;
        address payable addr;
        uint amount;
    }

    enum State {
        unfunded,
        prefunded,
        funded
    }

    constructor(uint _fundingGoal, SponsorFunding _sponsorFunding, DistributeFunding _distributeFunding) payable {
        fundingGoal = _fundingGoal * (10 ** 18);
        sponsorFunding = _sponsorFunding;
        distributeFunding = _distributeFunding;
        currentState = State.unfunded;
        funding = 0;
        index = 0;
        owner = msg.sender;
    }

    modifier goalNotReached() {
        if (currentState != State.unfunded) {
            revert("Goal already reached");
        }
        _;
    }

    modifier goalReached() {
        if (currentState == State.unfunded) {
            revert("You cannot perform this operation if goal is not reached");
        }
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only the contract owner has permission to perform this action");
        _;
    }

    modifier hasContributed() {
        if(contributors[msg.sender].amount == 0) {
            revert ("You must contribute to be able to withdraw an amount");
        }
        _;
    }

    function contribute() goalNotReached payable external {
        uint contributionValue = msg.value;
        contributors[msg.sender] = Contributor(index, payable(msg.sender), contributionValue);
        funding += contributionValue;
        index++;
        
        if (fundingGoal <= funding) {
            currentState = State.prefunded;
        }
    }

    function withdraw(uint requestedValue) goalNotReached hasContributed payable external {
        requestedValue = requestedValue * (10 ** 18);
        if (requestedValue > contributors[msg.sender].amount) {
            revert ("You cannot withdraw an amount which is higher than your contribution");
        }
        else {
            payable(msg.sender).transfer(requestedValue);
            contributors[msg.sender].amount -= requestedValue;
            funding -= requestedValue;
        }
    }

    function askSponsorFunding() isOwner goalReached external payable{
        sponsorFunding.executeSponsorshipTransaction(funding);
        funding = getBalance();
        currentState = State.funded;
    }

    function transferFundsToDistributeFunding() isOwner goalReached external payable {
        emit BeforeBalanceSent(address(distributeFunding), funding, getBalance());
        address add = address(distributeFunding);
        require(funding <= getBalance(), "Funding grater than balance");
        payable(add).transfer(funding);
        emit AfterBalanceSent(funding);
        distributeFunding.distributeFunds();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getCurrentState() public view returns (string memory) {
        if (currentState == State.unfunded) {
            return "Funding goal is not reached and state is unfunded";
        }
        else if (currentState == State.prefunded) {
            return "Funding goal was reached and state is prefunded";
        }
        else {
            return "Funding goal was reached and state is funded";
        }
    }

    fallback() external payable {}
    
    receive() external payable {}
}