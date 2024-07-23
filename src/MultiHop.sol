// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

contract MultiHop {
    /**
     *  PERFORM A MULTI-HOP SWAP WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 10 MKR.
     *  The challenge is to swap the contract entire MKR balance for ELON token, using WETH as the middleware token.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performMultiHopWithRouter(address mkr, address weth, address elon, uint256 deadline) public {
        // construct a path with MKR -> WETH -> ELON
        address[] memory path = new address[](3);
        path[0] = mkr;
        path[1] = weth;
        path[2] = elon;

        // trade all of the MKR
        uint256 amountInExact = IERC20(mkr).balanceOf(address(this));
        // get the minimum amount of ELON to receive
        uint256 amountETHOutMin = IUniswapV2Router(router).getAmountsOut(amountInExact, path)[1];
        uint256 amountOutMin = IUniswapV2Router(router).getAmountsOut(amountInExact, path)[2];

        // approve the router to transfer all the tokens along the path
        IERC20(mkr).approve(router, amountInExact);
        IERC20(weth).approve(router, amountETHOutMin);

        IUniswapV2Router(router).swapExactTokensForTokens(
            amountInExact,
            amountOutMin,
            path,
            address(this),
            deadline
        );

        IERC20(mkr).approve(router, 0);
        IERC20(weth).approve(router, 0);
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount of input tokens to swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses.
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

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
