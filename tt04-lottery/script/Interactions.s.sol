// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Raffle} from "../src/Raffle.sol";
import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        (uint256 subId,) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    /**
     * @notice Creates a subscription on the VRF Coordinator
     * @dev This function creates a subscription on the VRF Coordinator and returns the subscription ID and the VRF Coordinator address
     * @param vrfCoordinator The address of the VRF Coordinator
     * @return subId The subscription ID
     * @return vrfCoordinator The address of the VRF Coordinator
     */
    function createSubscription(address vrfCoordinator) public returns (uint256, address) {
        console2.log("Creating subscription on chainid", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        console2.log("Subscription ID:", subId);
        console2.log("Update update the sub-ID in your helperConfig");
        return (subId, vrfCoordinator);
    }

    function run() external {
        createSubscriptionUsingConfig();
    }
}
