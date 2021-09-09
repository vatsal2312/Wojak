// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


contract ICO is Ownable  {
     
    using SafeMath for uint256;
    // The token we are selling
    IBEP20 private token;

    //fund goes to
    address private beneficiary;

    // the UNIX timestamp start date of the crowdsale
    uint256 private startsAt;

    // the UNIX timestamp end date of the crowdsale
    uint256 private endsAt;
    
    // the price of token
    uint256 private TokenPerBNB;
    
    // Has this crowdsale been finalized
    bool private finalized = false;

    // the number of tokens already sold through this contract
    uint256 private tokensSold = 0;

    // the number of ETH raised through this contract
    uint256 private weiRaised = 0;

    // How many distinct addresses have invested
    uint256 private investorCount = 0;
    
    uint256 private reflectionPercent = 1;
    
    uint256 private marketingPercent =  1;
    
    uint256 private rewardsPercent  = 1;
    
    uint256 private sellrewardsPercent  = 2;
    
    address private marketingWallet = 0xdA4B161470A163F58D2F678E85EbFda4F7d24662;
    address private rewardsWallet = 0xE3D91958f46290F77BD6FB968Ff4060304A3309F;
    address private reflectionWallet = 0xdA4B161470A163F58D2F678E85EbFda4F7d24662;
    
    
    // How much ETH each address has invested to this crowdsale
    mapping (address => uint256) private investedAmountOf;

    // A new investment was made
    event Invested(address investor, uint256 weiAmount, uint256 tokenAmount);
    
    // Crowdsale Start time has been changed
    event StartsAtChanged(uint256 startsAt);
    
    // Crowdsale end time has been changed
    event EndsAtChanged(uint256 endsAt);
    
    // Calculated new price
    event RateChanged(uint256 oldValue, uint256 newValue);
    
    constructor (address _beneficiary, address _token)  {
        beneficiary = _beneficiary;
        token = IBEP20(_token);
    }
    
    function investInternal(address receiver) private {
        uint256 selltax;
        require(!finalized);
        require(startsAt <= block.timestamp && endsAt > block.timestamp);
        if(investedAmountOf[receiver] == 0) {
            investorCount++;     // A new investor
        }
        uint256 tokensAmount = (msg.value).mul(TokenPerBNB).div(10**10);  
        investedAmountOf[receiver] += msg.value;                    
        tokensSold += tokensAmount;     // Update totals
        weiRaised += msg.value;
        // Transfer Token to owner's address      
        token.transfer(marketingWallet, tokensAmount.mul(marketingPercent).div(100)); // TransferFee
        token.transfer(reflectionWallet, tokensAmount.mul(reflectionPercent).div(100));
        token.transfer(rewardsWallet, tokensAmount.mul(rewardsPercent).div(100));
        token.transfer(receiver, tokensAmount.sub((marketingPercent.add(reflectionPercent).add(rewardsPercent).add(2)).mul(tokensAmount).div(100)));
        // Transfer Fund to owner's address
        selltax = (marketingPercent.add(sellrewardsPercent).add(reflectionPercent).add(3)).mul(address(this).balance).div(100);
        payable(marketingWallet).transfer((address(this).balance).mul(marketingPercent).div(100));
        payable(rewardsWallet).transfer((address(this).balance).mul(sellrewardsPercent).div(100));
        payable(reflectionWallet).transfer((address(this).balance).mul(reflectionPercent).div(100));
        payable(beneficiary).transfer((address(this).balance).sub(selltax));
        // Emit an event that shows invested successfully
        emit Invested(receiver, msg.value, tokensAmount);
    }

    
    function invest() public payable {
        investInternal(msg.sender);
    }

    function setStartsAt(uint256 time) onlyOwner public {
        require(!finalized);
        startsAt = time;
        emit StartsAtChanged(startsAt);
    }
    function setEndsAt(uint256 time) onlyOwner public {
        require(!finalized);
        endsAt = time;
        emit EndsAtChanged(endsAt);
    }
    function setRate(uint256 value) onlyOwner public {
        require(!finalized);
        require(value > 0);
        emit RateChanged(TokenPerBNB, value);
        TokenPerBNB = value;
    }

    function finalize() public onlyOwner {
        // Finalized Pre crowdsele.
        finalized = true;
        uint256 tokensAmount = token.balanceOf(address(this));
        token.transfer(beneficiary, tokensAmount);
    }
    
    function getSaleStartTime() public view returns (uint256){
        return startsAt;
    }
    
    function getSaleEndTime() public view returns (uint256){
        return endsAt;
    }
    
    function getTokenPrice() public view returns (uint256){
        return TokenPerBNB;
    }
}


