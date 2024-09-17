// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title MockV3Aggregator
/// @notice 这是一个模拟的Chainlink价格预言机合约,用于测试目的
/// @dev 实现了AggregatorV3Interface接口,提供了固定的价格数据
/// @custom:mock 这是一个模拟合约,不应在生产环境中使用

contract MockV3Aggregator is AggregatorV3Interface {
    uint8 public constant DECIMALS = 8;  
    int256 public constant INITIAL_PRICE = 2000e8;  // 1ETH = 2000 USD
  
    uint256 private s_roundId;
    int256 private s_answer;
    uint256 private s_startedAt;
    uint256 private s_updatedAt;
    uint80 private s_answeredInRound;

    constructor() {
        s_roundId = 0;
        s_answer = INITIAL_PRICE;
        s_startedAt = block.timestamp;
        s_updatedAt = block.timestamp;
        s_answeredInRound = 0;
    }

    function decimals() external pure override returns (uint8) {
        return DECIMALS;
    }

    function description() external pure override returns (string memory) {
        return "Mock V3 Aggregator";
    }

    function version() external pure override returns (uint256) {
        return 4;
    }

    function getRoundData(uint80 _roundId) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (
            _roundId,
            s_answer,
            s_startedAt,
            s_updatedAt,
            s_answeredInRound
        );
    }

    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (
            uint80(s_roundId),
            s_answer,
            s_startedAt,
            s_updatedAt,
            uint80(s_answeredInRound)
        );
    }

    function updateAnswer(int256 _answer) public {
        s_roundId++;
        s_answer = _answer;
        s_startedAt = block.timestamp;
        s_updatedAt = block.timestamp;
        s_answeredInRound = uint80(s_roundId);
    }
}

