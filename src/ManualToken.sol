// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ManualToken {
    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return "RBToken";
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether; // 100 * 10^18
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function symbol() public pure returns (string memory) {
        return "RB";
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(s_balances[msg.sender] >= _value, "Not enough tokens");
        s_balances[msg.sender] -= _value;
        s_balances[_to] += _value;
        return true;
    }
    
}
