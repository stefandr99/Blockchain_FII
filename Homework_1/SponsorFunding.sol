// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.17;

contract SponsorFunding {
    uint availableFunds;
    uint sponsorPercentage;
    address owner;
    address payable crowdContract;
    bool hasTransactedSponsorship;

    constructor (uint _sponsorPercentage) payable {
        if (_sponsorPercentage <= 0 || _sponsorPercentage > 100) {
            revert("The sponsorship percentage must be between 0 and 100");
        }

        availableFunds = msg.value;
        sponsorPercentage = _sponsorPercentage;
        owner = msg.sender;
        hasTransactedSponsorship = false;
    }

    modifier isOwner() {
        require(msg.sender == owner, "This operation can be performed only by contract owner");
        _;
    }

    modifier isCrowdContract () {
        require(msg.sender == crowdContract, "Only the Crowd Contract can perform this action!");
        _;
    }

    modifier sponsorshipNotTransacted () {
        require(hasTransactedSponsorship == false, "Sponsorship has already been transacted");
        _;
    }

    function setCrowdContract(address payable _crowdContract) isOwner external {
        crowdContract = _crowdContract;
    }

    function changeSponsorPercentage(uint _sponsorPercentage) isOwner public {
        if (_sponsorPercentage <= 0 || _sponsorPercentage > 100) {
            revert("The sponsorship percentage must be between 0 and 100");
        }

        sponsorPercentage = _sponsorPercentage;
    }

    function supplyFunds() isOwner public payable {
        availableFunds += msg.value;
    }

    function getSponsorship(uint amount) private view returns(uint) {
        return (amount * sponsorPercentage) / 100;
    }

    function executeSponsorshipTransaction(uint crowdBalance) isCrowdContract sponsorshipNotTransacted external {
        uint sponsorship = getSponsorship(crowdBalance);

        if (availableFunds >= sponsorship) {
            payable(msg.sender).transfer(sponsorship);
            hasTransactedSponsorship = true;
        }
        else {
            revert("There are not enough funds to perform this transaction");
        }
    }
}