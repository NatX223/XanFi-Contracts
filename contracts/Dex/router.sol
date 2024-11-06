// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./factory.sol";

contract Router {
    Factory public factory;
    address public purchaseToken;

    constructor(Factory _factory, address _purchaseToken) {
        factory = _factory;
        purchaseToken = _purchaseToken;
    }

    function swapExactTokens(address receiver, uint256 amountIn, IERC20 tokenIn, IERC20 tokenOut) external {
        address pairAddress = factory.getPair(address(tokenIn), address(tokenOut));
        require(pairAddress != address(0), "PAIR_NOT_FOUND");

        pair dexpair = pair(pairAddress);
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenIn.approve(pairAddress, amountIn);
        dexpair.swap(receiver, tokenIn, amountIn);
    }

    function addLiquidity(uint256 amountA, uint256 amountB, IERC20 tokenA, IERC20 tokenB) external {
        address pairAddress = factory.getPair(address(tokenA), address(tokenB));
        require(pairAddress != address(0), "PAIR_NOT_FOUND");

        pair dexpair = pair(pairAddress);
        tokenA.transferFrom(msg.sender, address(dexpair), amountA);
        tokenB.transferFrom(msg.sender, address(dexpair), amountB);
        dexpair.addLiquidity(amountA, amountB);
    }

    function getPoolPrice(address tokenIn) public view returns(uint256 price) {
        address pairAddress = factory.getPair(tokenIn, purchaseToken);
        pair dexpair = pair(pairAddress);
        price = dexpair.price(tokenIn);
    }
}