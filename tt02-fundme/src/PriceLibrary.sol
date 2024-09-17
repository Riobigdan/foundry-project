// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Sepolia testnet 0x694AA1769357215DE4FAC081bf1f309aDC325306 
// ZKSync Sepolia testnet 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceLibrary {
    // 获取价格,返回的是8位小数的USD价格 1ETH = ? USD
    function getPrice(AggregatorV3Interface a_priceFeed) internal view returns (uint256){
        (,int256 price,,,) = a_priceFeed.latestRoundData();  // price is 8 decimals USD
        return uint256(price);
    }

    // 获取weiAmount的USD价格 1Wei = ? USD 同样8位小数
    function weiToUsd(uint256 weiAmount, AggregatorV3Interface a_priceFeed) internal view returns (uint256){
        return (weiAmount * getPrice(a_priceFeed)) / 1e18;
    }

    // 获取转换率, n USD = ? ETH 
    function usdToEth (uint256 usdAmount, AggregatorV3Interface a_priceFeed) internal view returns (uint256){
        uint256 ethPrice = getPrice(a_priceFeed);
        uint256 ethAmount = (usdAmount * 1e16) / ethPrice;
        return ethAmount;
    }

      function getVersion(AggregatorV3Interface a_priceFeed) internal view returns (uint256){
        return a_priceFeed.version();
    }

    // 获取入场费,返回的是8位小数的USD价格 1ETH = ? USD
    function getEntranceFee(uint256 a_ethAmount, AggregatorV3Interface a_priceFeed) internal view returns (uint256){
        uint256 ethPrice = getPrice(a_priceFeed);
        uint256 ethAmountInUsd = (ethPrice * a_ethAmount * 1e18) / 1e8;
        return ethAmountInUsd;
    }
}