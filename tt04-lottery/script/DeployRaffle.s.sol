// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Raffle} from "../src/Raffle.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {FundSubscription, CreateSubscription} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperconfig.getConfig();

        if (config.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) =
                createSubscription.createSubscription(config.vrfCoordinator);
            // Fund the subscription with LINK token
            // FundSubscription fundSubscription = new FundSubscription();
            // fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link);
        }
        // vrf create link (sepolia) https://vrf.chain.link/sepolia/new
        // link token address doc https://docs.chain.link/docs/link-token-contracts/
        // so Fund the token contract with link token
        // 水龙头 https://faucets.chain.link/
        // 水龙头 google Cloud web3 https://web3.google.com/faucet
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.callbackGasLimit,
            config.subscriptionId
        );
        vm.stopBroadcast();

        return (raffle, helperconfig);
    }
}
