// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Raffle} from "../src/Raffle.sol";
import {Script} from "forge-std/Script.sol";

contract DeployRaffle is Script {
    function deployRaffle() public {
        // HelperConfig helperConfig = new HelperConfig();

        vm.startBroadcast();
        new Raffle(
            helperConfig.getVrfCoordinator(),
            helperConfig.getLinkToken(),
            helperConfig.getGasLane(),
            helperConfig.getSubscriptionId(),
            helperConfig.getCallbackGasLimit()
        );
        vm.stopBroadcast();
    }

    function run() external {}
}
