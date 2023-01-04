// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SampleToken.sol";

contract SampleTokenSale {
    
    SampleToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    address private owner;

    event Sell(address indexed _buyer, uint256 indexed _amount);

    constructor(SampleToken _tokenContract, uint256 _tokenPrice) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        tokensSold = 0;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only the contract owner has permission to perform this action");
        _;
    }

    modifier hasNotSoldYet() {
        require(tokensSold == 0, "You cannot change the token price after you have sold them! This action can create mistrust among token holders");
        _;
    }

    function changeTokenPrice(uint256 _newTokenPrice) isOwner hasNotSoldYet public {
        require (_newTokenPrice > 0, "New token price should be greater than zero");
        
        tokenPrice = _newTokenPrice;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == _numberOfTokens * tokenPrice);
        require(tokenContract.balanceOf(owner) >= _numberOfTokens);
        require(tokenContract.transferFrom(owner, msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function buyTokensWithoutConstaints(uint256 _numberOfTokens) public payable {
        uint256 payment = _numberOfTokens * tokenPrice;

        require(msg.value >= payment, "You haven't sent enough");
        require(tokenContract.balanceOf(owner) >= _numberOfTokens, "There are not enough tokens in the balance");
        require(tokenContract.askForPermissionToSell(msg.sender, _numberOfTokens), "You don't have token owner permission");
        require(tokenContract.transferFrom(owner, msg.sender, _numberOfTokens), "The transfer failed. Try again");

        // transfer the amount for the tokens
        payable(owner).transfer(msg.value);

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);

        if(msg.value > payment) {
            uint256 change = msg.value - payment;

            payable(msg.sender).transfer(change);
        }
    }

    function endSale() public {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(owner)));
        require(msg.sender == owner);
        
        payable(msg.sender).transfer(owner.balance);
    }

    fallback() external payable {}
    
    receive() external payable {}
}