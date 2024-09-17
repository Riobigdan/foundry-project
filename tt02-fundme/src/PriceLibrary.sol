// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Sepolia testnet 0x694AA1769357215DE4FAC081bf1f309aDC325306 
// ZKSync Sepolia testnet 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceLibrary {
    function getPrice(AggregatorV3Interface a_priceFeed) internal view returns (uint256){
        (,int256 price,,,) = a_priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface a_priceFeed) internal view returns(uint256){
        uint256 ethPrice = getPrice(a_priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount * 100) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion(AggregatorV3Interface a_priceFeed) internal view returns (uint256){
        return a_priceFeed.version();
    }
}