## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Install

```shell
$ curl -L https://foundry.paradigm.xyz | bash
foundryup
forge install openzeppelin/openzeppelin-contracts --no-commit

```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# ZeppelinToken 项目

这是一个使用 Solidity 和 OpenZeppelin 库创建的 ERC20 代币项目。

## 安装步骤

1. 克隆仓库：

   ```
   git clone https://github.com/你的用户名/ZeppelinToken.git
   cd ZeppelinToken
   ```

2. 安装依赖：

   ```
   forge install
   ```

3. 编译合约：

   ```
   forge build
   ```

4. 运行测试：

   ```
   forge test
   ```

5. 部署合约（请先配置好网络和私钥）：
   ```
   forge create src/ZeppelinToken.sol:ZeppelinToken --constructor-args 1000000000000000000000000 --rpc-url <你的RPC URL> --private-key <你的私钥>
   ```

## 项目结构

- `src/ZeppelinToken.sol`: 主要的代币合约
- `lib/openzeppelin-contracts`: OpenZeppelin 库
- `test/`: 测试文件目录

## 注意事项

- 确保你已安装了 Foundry 工具链
- 部署前请仔细检查初始供应量参数
- 在主网部署前，建议先在测试网进行充分测试

## 许可证

MIT
