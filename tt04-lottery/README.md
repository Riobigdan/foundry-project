# 03-lottery

## 安装依赖

```shell
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
```

# 去中心化抽奖合约

这是一个基于 Chainlink VRF 的去中心化抽奖智能合约。

## 功能

- 用户可以通过支付入场费参与抽奖
- 使用 Chainlink VRF 确保随机性和公平性
- 自动化开奖流程

## 主要组件

1. `enterRaffle()`: 用户参与抽奖
2. `checkUpkeep()`: 检查是否需要开奖
3. `performUpkeep()`: 触发开奖流程
4. `pickWinner()`: 选择获胜者
5. `fulfillRandomWords()`: 处理 VRF 回调并完成开奖

## 使用方法

1. 部署合约时设置参数：入场费、开奖间隔、VRF 配置等
2. 用户调用 `enterRaffle()` 并支付入场费参与
3. Chainlink Automation 定期调用 `checkUpkeep()` 和 `performUpkeep()`
4. 合约自动完成开奖并转账给获胜者

## 注意事项

- 需要正确配置 Chainlink VRF 和 Automation
- 确保合约有足够的 LINK 代币支付 VRF 费用

## 作者

Rio

## Tests

Deploy Script: `scripts/Deploy.s.sol`

- not work on Zksync
- on Sepolia Testnet, the subscription id is `777`

Test: `test/Raffle.t.sol`
