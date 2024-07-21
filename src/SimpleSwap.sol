// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract SimpleSwap {
    /**
     *  PERFORM A SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap any amount of WETH for USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    uint256 public constant TRADING_FEE_BPS = 30;

    function performSwap(address pool, address weth, address usdc) public {
        /**
         *     swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data);
         *
         *     amount0Out: the amount of USDC to receive from swap.
         *     amount1Out: the amount of WETH to receive from swap.
         *     to: recipient address to receive the USDC tokens.
         *     data: leave it empty.
         */

        IUniswapV2Pair pair = IUniswapV2Pair(pool);
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();

        uint256 amount0Out = 100;
        uint256 amount1In = amount0Out > 0 ? getAmountIn(amount0Out, reserve1, reserve0) : 0;

        IERC20(weth).approve(address(pair), amount1In);
        IERC20(weth).transfer(address(pair), amount1In);
        pair.swap(amount0Out, 0, address(this), "");
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        require(amountOut > 0, "UniswapReplica: INSUFFICIENT_REQUESTED_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapReplica: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 10_000;
        uint256 denominator = (reserveOut - amountOut) * (10_000 - TRADING_FEE_BPS);
        amountIn = (numerator / denominator) + 1;
    }
}
