// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Raffle} from "../src/Raffle.sol";
import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig, CodeChainCode} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

/**
 * @title CreateSubscription
 * @author rio
 * @notice  本质是创建一个订阅，并返回订阅ID和vrfCoordinator地址
 */
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

/**
 * @title FundSubscription
 * @author rio
 * @notice 本质是给订阅合约打钱 AddaCunsumer
 * @dev ref https://docs.chain.link/docs/vrf/v2/subscription/fund-a-subscription/
 */
contract FundSubscription is Script, CodeChainCode {
    uint256 public constant FUND_AMOUNT = 0.001 ether; // Adjusted amount based on the balance

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken) public {
        console2.log("Funding subscriptiono id:", subscriptionId);
        console2.log("Using vrfCoordinator:", vrfCoordinator);
        console2.log("Using linkToken:", linkToken);
        console2.log("On ChainId:", block.chainid);

        if (block.chainid == ANVIL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            console2.log("Current balance:", LinkToken(linkToken).balanceOf(address(this)));
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}
