// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract SimpleSwapWithRouter {
    /**
     *  PERFORM A SIMPLE SWAP USING ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 ETH.
     *  The challenge is to swap any amount of ETH for USDC token using Uniswapv2 router.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performSwapWithRouter(address[] calldata path, uint256 deadline) public {
        // get the amount of ETH in the contract
        uint256 ethAmount = address(this).balance;

        // approve the router to transfer all the tokens along the path?
        
        // swap ETH for USDC
        IUniswapV2Router(router).swapExactETHForTokens{value: ethAmount}(
            0, // amountOutMin
            path,
            address(this),
            deadline
        );
    }

    receive() external payable {}
}

interface IUniswapV2Router {
    /**
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
}
