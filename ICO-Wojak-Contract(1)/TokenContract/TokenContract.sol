// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./BEP20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract TokenContract is BEP20, Ownable{
    using SafeMath for uint256;
    
    uint256  _totalSupply = 50000000000 * 10 ** 8;
    
    uint256 private teamFunds = 3;
    uint256 private marketingFunds = 5;
    uint256 private rewardFunds = 9;
    uint256 private advisorFunds = 2;
    uint256 private infrastructureFunds = 8;
    uint256 private helpFunds = 2;
    
    uint256 private antiWhaleDuration = 7200;
  
    mapping(address => uint256) private antiWhale;
    
    mapping (address => uint256) private antiWhaleTime;
    
    address private teamWallet = 0x14d5EC6907Dbe9c1e7B33783A7D8FEA8465738d8;
    address private advisorWallet = 0x14d5EC6907Dbe9c1e7B33783A7D8FEA8465738d8;
    address private infrastructureWallet = 0x14d5EC6907Dbe9c1e7B33783A7D8FEA8465738d8;
    address private helpWallet = 0x14d5EC6907Dbe9c1e7B33783A7D8FEA8465738d8;
    address private reflectionWallet = 0xdA4B161470A163F58D2F678E85EbFda4F7d24662;
    address private marketingWallet = 0xE3D91958f46290F77BD6FB968Ff4060304A3309F;
    address private rewardWallet = 0x14d5EC6907Dbe9c1e7B33783A7D8FEA8465738d8;
    
    constructor (string memory name, string memory symbol) BEP20(name, symbol) {
        _mint(msg.sender, _totalSupply.sub((marketingFunds.add(teamFunds).add(rewardFunds).add(advisorFunds).add(infrastructureFunds).add(helpFunds)).mul(_totalSupply).div(100)));
        _mint(marketingWallet, _totalSupply.mul(marketingFunds).div(100));
        _mint(teamWallet, _totalSupply.mul(teamFunds).div(100));
        _mint(rewardWallet, _totalSupply.mul(rewardFunds).div(100));
        _mint(advisorWallet, _totalSupply.mul(advisorFunds).div(100));
        _mint(infrastructureWallet, _totalSupply.mul(infrastructureFunds).div(100));
        _mint(helpWallet, _totalSupply.mul(helpFunds).div(100));
    }
     
    function burn(uint256 amount) external  {
        _burn(msg.sender, amount);
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(antiWhale[sender] + antiWhaleDuration < block.timestamp || antiWhaleTime[sender] <=  _totalSupply.mul(0.5 * 10**6).div(100),"Nobody can own more than 0.5% of the total supply"); 
        require(balanceOf(recipient) + amount <= _totalSupply.mul(1 * 10**6).div(100), "1 % max hold");
        require( amount < _totalSupply.mul(0.5 * 10**6).div(100), "Amount must be greater than 0.5%");
        
        if (antiWhale[sender] + antiWhaleDuration < block.timestamp && antiWhaleTime[sender] >=  _totalSupply.mul(0.5 * 10**6).div(100))
        {
            antiWhaleTime[sender] = 0;
        }
        
        antiWhale[sender] = block.timestamp;
        
        antiWhaleTime[sender] += amount;  

        super._transfer(sender, recipient, amount);
    }
}