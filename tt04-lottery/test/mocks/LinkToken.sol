// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/**
 * @title LinkToken
 * @author
 * @notice 创建一个ERC677Receiver接口，用于接收ERC677代币的转移
 */
interface ERC677Receiver {
    function onTokenTransfer(address from, uint256 amount, bytes calldata data) external returns (bool);
}

/**
 * @title LinkToken
 * @author
 * @notice 创建一个ERC677Receiver接口，用于接收ERC677代币的转移
 */
contract LinkToken is ERC20 {
    uint256 constant INITIAL_SUPPLY = 1000000000000000000;
    uint8 constant DECIMALS = 18;

    constructor() ERC20("Chainlink Token", "LINK", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function transferAndCall(address to, uint256 amount, bytes calldata data) public returns (bool) {
        return ERC677Receiver(to).onTokenTransfer(msg.sender, amount, data);
    }
}
