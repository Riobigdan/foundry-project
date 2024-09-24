// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@solmate/tokens/ERC20.sol";

interface ERC677Receiver {
    /**
     * @notice 接收代币的回调函数
     * @param _from 发送代币的地址
     * @param _value 转移的代币数量
     * @param _data 回调函数的数据
     */
    function onTokenTransfer(address _from, uint256 _value, bytes calldata _data) external;
}

/**
 * @title LinkToken
 * @author
 * @notice LinkToken 继承自 ERC20，这是一个标准的代币实现，提供了基本的代币功能如余额追踪和转账。
 */
contract LinkToken is ERC20 {
    uint256 constant INITIAL_SUPPLY = 1000000000000000000;
    uint8 constant DECIMALS = 18;

    /**
     * @notice 构造函数，初始化代币供应量
     */
    constructor() ERC20("Chainlink Token", "LINK", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @notice 铸造代币
     * @param to 接收代币的地址
     * @param amount 铸造的代币数量
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    /**
     * @notice 转移代币并调用回调函数
     * @param to 接收代币的地址
     * @param amount 转移的代币数量
     * @param data 回调函数的数据
     * @return 是否成功转移代币
     */
    function transferAndCall(address to, uint256 amount, bytes calldata data) public returns (bool) {
        ERC677Receiver(to).onTokenTransfer(msg.sender, amount, data);
        return true;
    }

    /**
     * @notice private 合约回调函数
     * @param _to 接收代币的地址
     * @param _value 转移的代币数量
     * @param _data 回调函数的数据
     */
    function contractFallback(address _to, uint256 _value, bytes memory _data) private {
        ERC677Receiver(_to).onTokenTransfer(msg.sender, _value, _data);
    }

    /**
     * @notice 判断地址是否为合约
     * @param account 要判断的地址
     * @return 是否为合约
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
