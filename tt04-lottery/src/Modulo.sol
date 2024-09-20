// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Modulo {
    function modulo(uint256 a, uint256 b) public pure returns (uint256) {
        return a % b;
    }

    function modulo2(uint256 a) public pure returns (uint256) {
        return a % 2;
    }

    function modulo10(uint256 a) public pure returns (uint256) {
        return a % 10;
    }
}
