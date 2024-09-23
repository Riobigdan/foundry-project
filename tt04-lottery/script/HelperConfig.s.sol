// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeChainCode {
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ANVIL_CHAIN_ID = 31337;

    // @dev VRF Mock Value
    uint96 public constant ANVIL_BASE_FEE = 0.25 ether;
    uint96 public constant ANVIL_GAS_PRICE = 1e9;
    int256 public constant ANVIL_WEI_PER_UNIT_LINK = 1e18;
}

contract HelperConfig is Script, CodeChainCode {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator; // 链上vrfCoordinator地址
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
        address link;
    }

    /* @Errors */
    error HelperConfig__NetworkNotConfigured(uint256 chainId);

    NetworkConfig public localNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfig;

    /* @constructor */
    constructor() {
        networkConfig[SEPOLIA_CHAIN_ID] = getSepoliaConfig();
    }

    /**
     * @dev 根据chainId获取网络配置
     * @param chainId 链id
     * @return NetworkConfig 网络配置
     */
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfig[chainId].vrfCoordinator != address(0)) {
            return networkConfig[chainId];
        } else if (chainId == ANVIL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else {
            revert HelperConfig__NetworkNotConfigured(chainId);
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 84197343675464504425414728616412005354770664351257355224211786028223568062920,
            callbackGasLimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    /**
     * @dev 获取本地的anvil配置
     * 因为要部署一些合约 所以不是pure
     */
    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // @dev 如果已经配置了 直接返回
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        // @dev 如果没有配置 则创建MockVrfCoordinator
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
            ANVIL_BASE_FEE, // baseFee
            ANVIL_GAS_PRICE, // gasPrice
            ANVIL_WEI_PER_UNIT_LINK // weiPerUnitLink
        );
        // @dev Deploy Link Token
        LinkToken linkToken = new LinkToken();

        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinator),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            link: address(linkToken)
        });
        return localNetworkConfig;
    }
}
