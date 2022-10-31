// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.17;

contract DistributeFunding {
    uint public shares;
    uint public availableShares;
    address owner;
    address payable crowdContract;
    mapping(address => uint) shareholdersMapping;
    address payable[] shareholders;

    constructor() {
        shares = 100;
        availableShares = shares;
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "This operation can be performed only by contract owner");
        _;
    }

    modifier isCrowdContract () {
        require(msg.sender == crowdContract, "Only the Crowd Contract can perform this action!");
        _;
    }

    function setCrowdContract(address payable _crowdContract) isOwner external {
        crowdContract = _crowdContract;
    }

    function addSharesToShareholder(uint numberOfShares, address payable shareholderAddress) isOwner public {
        if(numberOfShares <= availableShares) {
            availableShares -= numberOfShares;
            shareholdersMapping[shareholderAddress] += numberOfShares;
            shareholders.push(shareholderAddress);
        }
        else {
            revert("Unfortunatelly, there are not enough available shares");
        }
    }

    function getShareValue(uint funds, uint percentage) private pure returns(uint) {
        return (funds * percentage) / 100;
    }

    function distributeFunds() isCrowdContract external payable {
        uint funds = getBalance();
        for(uint i = 0; i < shareholders.length; i++){
            uint shareToTransact = getShareValue(funds, shareholdersMapping[shareholders[i]]);
            payable(shareholders[i]).transfer(shareToTransact);
        }
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}