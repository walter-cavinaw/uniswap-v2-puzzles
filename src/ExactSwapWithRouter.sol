// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "forge-std/console.sol";

contract ExactSwapWithRouter {
    /**
     *  PERFORM AN EXACT SWAP WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using UniswapV2 router.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performExactSwapWithRouter(address weth, address usdc, uint256 deadline) public {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdc;

        uint256 amountOutMin = 1337 * (10 ** IERC20(usdc).decimals());

        uint256 amountInExact = IUniswapV2Router(router).getAmountsIn(amountOutMin, path)[0];
                // approve the router to transfer all the tokens along the path
        IERC20(weth).approve(router, amountInExact);

        IUniswapV2Router(router).swapExactTokensForTokens(
            amountInExact,
            amountOutMin,
            path,
            address(this),
            deadline
        );

        IERC20(weth).approve(router, 0);
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount of input tokens to swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
}
