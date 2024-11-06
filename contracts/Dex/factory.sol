// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./pair.sol";

contract Factory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed tokenA, address indexed tokenB, address pair, uint);

    function createPair(IERC20 tokenA, IERC20 tokenB) external returns (address pairAddress) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");
        require(getPair[address(tokenA)][address(tokenB)] == address(0), "PAIR_EXISTS");
        
        pair newPair = new pair(tokenA, tokenB);
        pairAddress = address(newPair);

        getPair[address(tokenA)][address(tokenB)] = pairAddress;
        getPair[address(tokenB)][address(tokenA)] = pairAddress; // Handle both directions
        allPairs.push(pairAddress);

        emit PairCreated(address(tokenA), address(tokenB), pairAddress, allPairs.length);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
}
