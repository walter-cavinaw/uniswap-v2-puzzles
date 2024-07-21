// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";
import "forge-std/console.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */
    function addLiquidity(address usdc, address weth, address pool, uint256 usdcReserve, uint256 wethReserve) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // what checks does the router make?

        // which of token0 and token1 are usdc and weth?
        (address token0, address token1) = pair.token0() == usdc ? (usdc, weth) : (weth, usdc);
        
        // get the balance of the contract for token0 and token1
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        // get pool reserves
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestampLast;
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();

        // calculate the amount of USDC and WETH to deposit
        (uint256 amount0, uint256 amount1) = _calcDepositAmounts(balance0, balance1, 0, 0, reserve0, reserve1);

        // approve the pair contract to transfer the tokens
        IERC20(token0).approve(address(this), amount0);
        IERC20(token1).approve(address(this), amount1);

        // transfer USDC and WETH to the pair contract
        IERC20(token0).transferFrom(address(this), address(pair), amount0);
        IERC20(token1).transferFrom(address(this), address(pair), amount1);

        // call the mint function in the pair contract
        pair.mint(msg.sender);

        // see available functions here: https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol
    }

    /**
     * @notice Calculates the deposit amounts given an acceptable range
     * @param maxToken0 Maximum amount of token0 to deposit.
     * @param maxToken1 Maximum amount of token1 to deposit.
     * @param minToken0 Minimum amount of token0 to deposit. protects against unexpected changes.
     * @param minToken1 Minimum amount of token1 to deposit. protects against unexpected changes.
     */
    function _calcDepositAmounts(uint256 maxToken0, uint256 maxToken1, uint256 minToken0, uint256 minToken1, uint256 reserve0, uint256 reserve1)
        private
        pure
        returns (uint256 amount0, uint256 amount1)
    {
        if (reserve0 == 0 && reserve1 == 0) {
            (amount0, amount1) = (maxToken0, maxToken1);
        } else {
            uint256 amount1Optimal = maxToken0 * reserve1 / reserve0;
            if (amount1Optimal <= maxToken1) {
                require(amount1Optimal >= minToken1, "UniswapReplica: INSUFFICIENT_AMOUNT_TOKEN_1");
                (amount0, amount1) = (maxToken0, amount1Optimal);
            } else {
                uint256 amount0Optimal = maxToken1 * reserve0 / reserve1;
                assert(amount0Optimal <= maxToken0);
                require(amount0Optimal >= minToken0, "UniswapReplica: INSUFFICIENT_AMOUNT_TOKEN_0");
                (amount0, amount1) = (amount0Optimal, maxToken1);
            }
        }
    }
}
