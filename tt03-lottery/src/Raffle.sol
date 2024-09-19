// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/dev/vrf/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle
 * @author Rio
 * @notice This contract is for creating a decentralized raffle
 * @dev This implements Chainlink VRF to ensure fairness
 */

contract Raffle is VRFConsumerBaseV2Plus {
    using VRFV2PlusClient for VRFV2PlusClient.RandomWordsRequest;
    /* Errors */
    error Raffle__NotEnoughEthSent();
    error Raffle__TooEarly();

    /* Type Declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /* Constant Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint32 private constant CALLBACK_GAS_LIMIT = 100000;

    /* State Variables */
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    /* Events */
    event RaffleEntered(address indexed player);

    // @param entranceFee 入场费
    // @param interval 开奖的时间间隔
    // @param vrfCoordinator VRF 的 coordinator
    // @param gasLane VRF 的 gas lane 作为 key hash
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = gasLane; 
        i_subscriptionId = subscriptionId;
        s_lastTimeStamp = block.timestamp;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        // emit event
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external view{
        // 相当于就是计时
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert Raffle__TooEarly();
        }
    
        /**
         * @param keyHash is the gas lane key hash
         * @param subId is the subscription id
         * @param requestConfirmations ChainLine回应之前等待的确认数
         * @param callbackGasLimit 回调函数消耗的 gas limit
         * @param numWords 随机数个数
         * @param extraArgs is the extra arguments
         */
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: CALLBACK_GAS_LIMIT,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
        });

        // @s_vrfCoordinator 是 VRFConsumerBaseV2Plus 的一个属性，表示 VRF 的 coordinator
        // @requestRandomWords 是 VRFConsumerBaseV2Plus 的一个函数，表示请求随机数
        // @VRFV2PlusClient 是 VRFConsumerBaseV2Plus 的一个结构体，表示 VRF 的请求
        // uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    /* Getter Functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
