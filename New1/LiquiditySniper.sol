// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/Uniswap.sol";

contract LiquiditySniper is Ownable {
    // MAINNET:
    address private constant FACTORY = address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    address private constant ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant WBNB =  address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        
    
    //TESTNET:
    //address private constant FACTORY = address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc);
    //address private constant ROUTER = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    //address private constant WBNB = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);    
        
        
        
        
       function liquidifyAndBuy(
        address tokenAddress,
        uint256 amountTokenDesired,
        uint256 amountEthDesired,
        uint256 buyBackAmount
    ) external payable {
        require(
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                address(this),
                amountTokenDesired * 10**9
            ),
            "transferFrom failed."
        );

        require(
            IERC20(tokenAddress).approve(ROUTER, amountTokenDesired * 10**9),
            "approval failed."
        );

        (uint amountToken, uint amountETH, uint liquidity) = addLiquidity(
            tokenAddress,
            amountTokenDesired * 10**9,
            amountEthDesired * 10**18,
            amountTokenDesired * 10**9,
            amountEthDesired * 10**18
        );

        require(amountToken > 0 && amountETH > 0 && liquidity > 0, "add liquidity failed");

        uint256 _amountOutMin = getAmountOutMin(tokenAddress, buyBackAmount * 10**18 );

        uint[] memory amounts = buyToken(tokenAddress, buyBackAmount * 10**18, _amountOutMin);

        require(amounts[amounts.length - 1] > 0, "token swap failed");
    }

    function addLiquidity(
        address tokenAddress,
        uint256 amountTokenDesired,
        uint256 amountEthDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin
    ) private returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH, liquidity) = IUniswapV2Router(ROUTER).addLiquidityETH{value: amountEthDesired}(
            tokenAddress,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            msg.sender,
            block.timestamp
        );
    }

    function buyToken(
        address tokenAddress,
        uint256 buyBackAmount,
        uint256 _amountOutMin
    ) private returns (uint[] memory amounts){
        address[] memory path;
        path = new address[](2);
        path[0] = WBNB;
        path[1] = tokenAddress;

        amounts = IUniswapV2Router(ROUTER).swapExactETHForTokens{value: buyBackAmount}(
            _amountOutMin,
            path,
            msg.sender,
            block.timestamp + 2000
        );
    }

    function getAmountOutMin(address _tokenOut, uint256 buyBackAmount)
        private
        view
        returns (uint256)
    {
        address[] memory path;
        path = new address[](2);
        path[0] = WBNB;
        path[1] = _tokenOut;

        uint256[] memory amountOutMins = IUniswapV2Router(ROUTER).getAmountsOut(
            buyBackAmount,
            path
        );

        return amountOutMins[path.length - 1];
    }

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function deposit(uint256 amount) public payable {
        require(msg.value == amount, "msg.value != amount");
        // nothing else to do!
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}

