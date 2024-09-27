# 去中心化抽奖合约

基于 Chainlink VRF 的去中心化抽奖智能合约。

## 安装依赖

```shell
rm -rf lib
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
forge install foundry-rs/forge-std --no-commit
forge install transmissions11/solmate --no-commit
```

## Test

```shell
forge test
forge coverage > test/coverage.txt
forge coverage --report debug > test/coverage_debug.txt
```

---

## 功能

- 用户支付入场费参与抽奖
- Chainlink VRF 保证随机性和公平性
- 自动开奖流程

## 主要组件

1. `enterRaffle()`: 参与抽奖
2. `checkUpkeep()`: 检查是否需要开奖
3. `performUpkeep()`: 触发开奖
4. `pickWinner()`: 选择获胜者
5. `fulfillRandomWords()`: 处理 VRF 回调并完成开奖

## 使用方法

1. 部署合约设置参数：入场费、开奖间隔、VRF 配置等
2. 用户调用 `enterRaffle()` 支付入场费参与
3. Chainlink Automation 定期调用 `checkUpkeep()` 和 `performUpkeep()`
4. 合约自动开奖并转账给获胜者

## 注意事项

- 正确配置 Chainlink VRF 和 Automation
- 确保合约有足够 LINK 代币支付 VRF 费用

## 测试

部署脚本: `scripts/Deploy.s.sol`

- 不支持 Zksync
- Sepolia 测试网订阅 ID: `777`

测试文件: `test/Raffle.t.sol`

## 作者

Rio

## Tests

Deploy Script: `scripts/Deploy.s.sol`

- not work on Zksync
- on Sepolia Testnet, the subscription id is `777`

Test: `test/Raffle.t.sol`
