// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Raffle} from "../src/Raffle.sol";
import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig, CodeChainCode} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

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
    uint256 public constant FUND_AMOUNT = 3 ether; //3 Link

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address link = helperConfig.getConfig().link;
        fundSubscription(vrfCoordinator, subscriptionId, link);
    }

    /**
     * @notice Funds a subscription on the VRF Coordinator
     * @dev This function funds a subscription on the VRF Coordinator and returns the subscription ID and the VRF Coordinator address
     * @param vrfCoordinator The address of the VRF Coordinator
     * @param subscriptionId The subscription ID
     * @param linkToken The address of the LINK token
     */
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
            // 获取合约的 LINK 余额

            // 获取 VRFCoordinator 的 LINK 余额
            uint256 coordinatorBalance = LinkToken(linkToken).balanceOf(vrfCoordinator);
            console2.log(unicode"VRFCoordinator 的 LINK 余额:", coordinatorBalance);

            // 如果合约余额不足，则报错
            require(coordinatorBalance >= FUND_AMOUNT, unicode"合约 LINK 余额不足");

            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }
    }

    function run() public {
        fundSubscriptionUsingConfig();
    }
}

/**
 * @title AddConsumer
 * @author rio
 * @notice 本质是给订阅合约打钱 AddaCunsumer
 * @dev ref https://docs.chain.link/docs/vrf/v2/subscription/fund-a-subscription/
 */
contract AddConsumer is Script {
    // need Foundry Devops
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subscriptionId);
    }

    function addConsumer(address mostRecentlyDeployed, address vrfCoordinator, uint256 subscriptionId) public {
        console2.log("Adding consumer to subscription id:", subscriptionId);
        console2.log("Using vrfCoordinator:", vrfCoordinator);
        console2.log("Using mostRecentlyDeployed:", mostRecentlyDeployed);

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subscriptionId, mostRecentlyDeployed);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}
