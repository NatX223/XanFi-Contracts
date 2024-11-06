// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract pair {
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(uint256 amountA, uint256 amountB) public {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

        reserveA += amountA;
        reserveB += amountB;
    }

    function swap(address recipient, IERC20 inputToken, uint256 inputAmount) public {
        require(inputAmount > 0, "Amount must be greater than zero");

        // Determine the output token and reserves based on the input token
        (IERC20 outputToken, uint256 inputReserve, uint256 outputReserve) = inputToken == tokenA 
            ? (tokenB, reserveA, reserveB) 
            : (tokenA, reserveB, reserveA);

        // Transfer the input token amount from the caller to the contract
        inputToken.transferFrom(msg.sender, address(this), inputAmount);

        // Calculate the output amount using the price formula
        uint256 outputAmount = getPrice(inputAmount, inputReserve, outputReserve);
        require(outputAmount <= outputReserve, "Not enough liquidity");

        // Update reserves
        if (inputToken == tokenA) {
            reserveA += inputAmount;
            reserveB -= outputAmount;
        } else {
            reserveB += inputAmount;
            reserveA -= outputAmount;
        }

        // Transfer the output token to the recipient
        outputToken.transfer(recipient, outputAmount);
    }


    function getPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        return (inputAmount * outputReserve) / inputReserve;
    }

    function price(address inputToken) public view returns(uint256 outputAmount) {
        (IERC20 outputToken, uint256 inputReserve, uint256 _outputReserve) = IERC20(inputToken) == tokenA 
        ? (tokenB, reserveA, reserveB)
        : (tokenA, reserveB, reserveA);

        uint256 inputAmount = 1;

        uint256 outputReserve = _outputReserve / (10 ** 6);

        uint256 _outputAmount = (inputAmount * outputReserve) / (inputReserve / (10 ** 18));

        outputAmount = _outputAmount * (10 ** 18);
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
}
