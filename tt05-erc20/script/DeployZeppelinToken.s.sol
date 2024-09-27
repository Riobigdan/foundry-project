// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ZeppelinToken} from "src/ZeppelinToken.sol";
import {Script} from "forge-std/Script.sol";

contract DeployZeppelinToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000;

    function run() external returns (ZeppelinToken) {
        vm.startBroadcast();
        ZeppelinToken zeppelinToken = new ZeppelinToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return zeppelinToken;
    }
}
