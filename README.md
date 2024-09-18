# FundMe 智能合约项目

## 项目简介

FundMe 是一个基于以太坊的众筹智能合约。它允许用户以 ETH 的形式进行捐款，并确保每次捐款的最小金额达到 1 美元的等值。合约所有者可以随时提取所有捐款。

## 主要功能

1. 捐款（fund）：用户可以向合约发送 ETH 进行捐款。
2. 提现（withdraw）：合约所有者可以提取所有捐款。
3. 价格转换：使用 Chainlink 预言机将 USD 转换为 ETH。

## 技术特点

- 使用 Solidity 0.8.18 编写
- 集成 Chainlink 预言机获取实时 ETH/USD 价格
- 实现了 receive 和 fallback 函数以处理直接转账
- 使用 PriceLibrary 进行价格相关计算

## 合约结构

- `FundMe.sol`：主合约文件
- `PriceLibrary.sol`：价格转换库

## 如何使用

1. 部署合约时需提供 Chainlink 价格预言机地址
2. 用户可以调用 `fund()` 函数进行捐款
3. 合约所有者可以调用 `withdraw()` 或 `withdrawCheaper()` 提取资金

```zsh
forge test
forge script script/DeployFundMe.s.sol --account Default --broadcast
```

## 注意事项

- 只有合约所有者可以提取资金
- 最小捐款金额为 1 美元的 ETH 等值
- 所有金额计算都考虑了 ETH 的 18 位小数和价格预言机的 8 位小数

## 贡献

欢迎提交 Pull Requests 来改进这个项目。对于重大更改，请先开 issue 讨论您想要改变的内容。

## 许可证

本项目采用 MIT 许可证。
