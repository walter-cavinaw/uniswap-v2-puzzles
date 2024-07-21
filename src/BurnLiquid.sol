// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract BurnLiquid {
    /**
     *  BURN LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 0.01 UNI-V2-LP tokens.
     *  Burn a position (remove liquidity) from USDC/ETH pool to this contract.
     *  The challenge is to use the `burn` function in the pool contract to remove all the liquidity from the pool.
     *
     */
    function burnLiquidity(address pool) public {
        /**
         *     burn(address to);
         *
         *     to: recipient address to receive tokenA and tokenB.
         */
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // get the balance of the contract for UNI-V2-LP tokens
        uint256 balance = IERC20(address(pair)).balanceOf(address(this));
        
        // approve the pair contract to transfer the tokens
        IERC20(address(pair)).approve(address(this), balance);

        // transfer UNI-V2-LP tokens to the pair contract
        IERC20(address(pair)).transferFrom(address(this), address(pair), balance);

        // call the burn function in the pair contract
        pair.burn(address(this));


    }
}
