// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.17;

contract DistributeFunding {
    uint public funds;
    uint public shares;
    uint public availableShares;
    address owner;
    address crowdContract;
    mapping(address => uint) shareholdersMapping;
    mapping(address => bool) withdrawedIncome;
    address [] shareholders;

    constructor() {
        shares = 100;
        availableShares = shares;
        owner = msg.sender;
        funds = 0;
    }

    modifier isOwner() {
        require(msg.sender == owner, "This operation can be performed only by contract owner");
        _;
    }

    modifier isCrowdContract () {
        require(msg.sender == crowdContract, "Only the Crowd Contract can perform this action");
        _;
    }

    modifier hasReceivedFunds()  {
        require(getBalance() > 0, "You cannot withdraw your income unless funds are not received");
        _;
    }

    function setCrowdContract(address payable _crowdContract) isOwner external {
        crowdContract = _crowdContract;
    }

    function addSharesToShareholder(uint numberOfShares, address shareholderAddress) isOwner public {
        if(numberOfShares <= availableShares) {
            availableShares -= numberOfShares;
            shareholdersMapping[shareholderAddress] += numberOfShares;
            withdrawedIncome[shareholderAddress] = false;
            shareholders.push(shareholderAddress);
        }
        else {
            revert("Unfortunatelly, there are not enough available shares");
        }
    }

    function getShareValue(uint funds2, uint percentage) private pure returns(uint) {
        return (funds2 * percentage) / 100;
    }

    function withdrawIncome() hasReceivedFunds public payable {
        if(funds == 0) {
            funds = getBalance();
        }

        require(isShareholder(msg.sender) == true, "You are not a shareholder, you cannot withdraw");
        require(withdrawedIncome[msg.sender] == false, "You have already withdrawed your income");

        uint shareToTransact = getShareValue(funds, shareholdersMapping[msg.sender]);
        payable(msg.sender).transfer(shareToTransact);
        withdrawedIncome[msg.sender] = true;
    }

    function isShareholder(address shareholder) private view returns(bool) {
        for(uint i = 0; i < shareholders.length; i++){
            if(shareholders[i] == shareholder) {
                return true;
            }
        }

        return false;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    fallback() external payable {}
    
    receive() external payable {}
}