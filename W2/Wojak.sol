// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract Wojak is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    WOJDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

    uint256 public swapTokensAtAmount = 2500000 * 10**9;
	uint256 public maxTxAmount = 250000000 * 10**9;
	uint256 public maxWalletAmount = 500000000 * 10**9;
	
    mapping(address => bool) public _isBlacklisted;

    uint256 public buyBUSDRewardsFee = 1;
    uint256 public buyMarketingFee = 1;
	uint256 public buyCharityFee = 1;
	uint256 public buyLiquidityFee = 2;
    uint256 public totalBuyFees = buyBUSDRewardsFee.add(buyMarketingFee).add(buyCharityFee).add(buyLiquidityFee);
	
	uint256 public sellBUSDRewardsFee = 2;
    uint256 public sellMarketingFee = 1;
	uint256 public sellCharityFee = 1;
	uint256 public sellLiquidityFee = 3;
    uint256 public totalSellFees = sellBUSDRewardsFee.add(sellMarketingFee).add(sellCharityFee).add(sellLiquidityFee);
	
	uint256 public marketingTokens;
	uint256 public charityTokens;
	uint256 public liquidityTokens;
	uint256 public rewardTokens;
	
    address public marketingWalletAddress = 0x0b3Af6219e7fDC90E51B2449e007238C88202F93;
	address public charityWalletAddress = 0xf97f828AE1CE2E936dC6A8B9181a89d028A730bd;
	
	uint256 private launchedAt;
	
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees
    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
	
	// exlcude from max holding limit
	mapping (address => bool) public _isExcludedFromMaxWallet;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
	
    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );
	
    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );
	
    constructor() public ERC20("Wojak", "WOJ") {

    	dividendTracker = new WOJDividendTracker();

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        //exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees
        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress, true);
		excludeFromFees(charityWalletAddress, true);
        excludeFromFees(address(this), true);
		
		// exclude from max holding limit
		excludeFromMaxWallet(owner(), true);
		excludeFromMaxWallet(marketingWalletAddress, true);
		excludeFromMaxWallet(charityWalletAddress, true);
		excludeFromMaxWallet(address(this), true);
		excludeFromMaxWallet(address(0), true);

        /* _mint is an internal function in ERC20.sol that is only called here, and CANNOT be called ever again */
        _mint(owner(), 50000000000 * 10**9);
    }

    receive() external payable {

  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "WOJ: The dividend tracker already has that address");

        WOJDividendTracker newDividendTracker = WOJDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "WOJ: The new dividend tracker must be owned by the WOJ token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "WOJ: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }
	
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "WOJ: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
	
	function excludeFromMaxWallet(address account, bool value) public onlyOwner {
	    _isExcludedFromMaxWallet[account] = value;
	}
	
    function setMarketingWallet(address payable wallet) external onlyOwner{
         marketingWalletAddress = wallet;
    }
	
	function setCharityWalletAddress(address payable wallet) external onlyOwner{
        charityWalletAddress = wallet;
    }
	
    function setBuyBUSDRewardsFee(uint256 value) external onlyOwner{
        buyBUSDRewardsFee = value;
    }
	
    function setBuyMarketingFee(uint256 value) external onlyOwner{
        buyMarketingFee = value;
    }
	
	function setBuyCharityFee(uint256 value) external onlyOwner{
        buyCharityFee = value;
    }
	
	function setBuyLiquiditFee(uint256 value) external onlyOwner{
        buyLiquidityFee = value;
    }
	
	function setSellBUSDRewardsFee(uint256 value) external onlyOwner{
        sellBUSDRewardsFee = value;
    }
	
    function setSellMarketingFee(uint256 value) external onlyOwner{
        sellMarketingFee = value;
    }
	
	function setSellCharityFee(uint256 value) external onlyOwner{
        sellCharityFee = value;
    }
	
	function setSellLiquiditFee(uint256 value) external onlyOwner{
        sellLiquidityFee = value;
    }
	
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "WOJ: The PanBUSDSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
	
    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }
	
	function setMaxWalletAmount(uint256 amount) public onlyOwner {
		 maxWalletAmount = amount;
	}

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "WOJ: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "WOJ: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "WOJ: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		dividendTracker.processAccount(msg.sender, false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
		
		if(from != owner() && to != owner()){
		   require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount");
		}
		
		if(launchedAt == 0 && automatedMarketMakerPairs[to]) {
			launchedAt = block.timestamp.add(2 hours);
		}
		
		if (!automatedMarketMakerPairs[to] && !_isExcludedFromMaxWallet[to]) {
		   require(balanceOf(to).add(amount) <= maxWalletAmount, "You are transferring too many tokens");
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;
			
			uint256 toMarketing = marketingTokens;
            swapAndSendToFee(toMarketing, marketingWalletAddress);
			marketingTokens.sub(toMarketing);
			
			uint256 toCharity = charityTokens;
			swapAndSendToFee(toCharity, charityWalletAddress);
			charityTokens.sub(toCharity);
            
			uint256 toLiquidity = liquidityTokens;
            swapAndLiquify(toLiquidity);
			liquidityTokens.sub(toLiquidity);
			
			uint256 toReward = rewardTokens;
            swapAndSendDividends(rewardTokens);
			rewardTokens.sub(toReward);
            swapping = false;
        }
		
        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
		
        if(takeFee) {
        	if(automatedMarketMakerPairs[to])
			{
			    if(block.timestamp <= launchedAt)
				{
				    uint256 fees = amount.mul(99).div(100);
				
					marketingTokens = marketingTokens.add(fees.div(totalSellFees).mul(sellMarketingFee));
					charityTokens = charityTokens.add(fees.div(totalSellFees).mul(sellCharityFee));
					liquidityTokens = liquidityTokens.add(fees.div(totalSellFees).mul(sellLiquidityFee));
					rewardTokens = rewardTokens.add(fees.div(totalSellFees).mul(sellBUSDRewardsFee));
					
					amount = amount.sub(fees);
					super._transfer(from, address(this), fees);
				}
				else
				{
				    uint256 fees = amount.mul(totalSellFees).div(100);
				
					marketingTokens = marketingTokens.add(fees.div(totalSellFees).mul(sellMarketingFee));
					charityTokens = charityTokens.add(fees.div(totalSellFees).mul(sellCharityFee));
					liquidityTokens = liquidityTokens.add(fees.div(totalSellFees).mul(sellLiquidityFee));
					rewardTokens = rewardTokens.add(fees.div(totalSellFees).mul(sellBUSDRewardsFee));
					
					amount = amount.sub(fees);
					super._transfer(from, address(this), fees);
				}
			    
        	}
			else
			{
			    uint256 fees = amount.mul(totalBuyFees).div(100);
				
				marketingTokens = marketingTokens.add(fees.div(totalBuyFees).mul(buyMarketingFee));
				charityTokens = charityTokens.add(fees.div(totalBuyFees).mul(buyCharityFee));
			    liquidityTokens = liquidityTokens.add(fees.div(totalBuyFees).mul(buyLiquidityFee));
				rewardTokens = rewardTokens.add(fees.div(totalBuyFees).mul(buyBUSDRewardsFee));
				
				amount = amount.sub(fees);
                super._transfer(from, address(this), fees);
			}
        }
		
        super._transfer(from, to, amount);
		
        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;
	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {
			
	    	}
        }
    }
	
    function swapAndSendToFee(uint256 tokens, address wallet) private  {
		uint256 initialBUSDBalance = IERC20(BUSD).balanceOf(address(this));
		swapTokensForUsd(tokens);
		uint256 newBalance = (IERC20(BUSD).balanceOf(address(this))).sub(initialBUSDBalance);
		IERC20(BUSD).transfer(wallet, newBalance);
    }
	
    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function swapTokensForEth(uint256 tokenAmount) private {
	
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function swapTokensForUsd(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSD;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );

    }

    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForUsd(tokens);
        uint256 dividends = IERC20(BUSD).balanceOf(address(this));
        bool success = IERC20(BUSD).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeBUSDDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }
}

contract WOJDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() public DividendPayingToken("WOJ_Dividen_Tracker", "WOJ_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 500000 * (10**9); //must hold 500000+ tokens
    }
	
    function _transfer(address, address, uint256) internal override {
        require(false, "WOJ_Dividend_Tracker: No transfers allowed");
    }
	
    function withdrawDividend() public override {
        require(false, "WOJ_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main WOJ contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "WOJ_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "WOJ_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
	
    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}
