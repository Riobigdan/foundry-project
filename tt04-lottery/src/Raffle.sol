// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle
 * @author Rio
 * @notice This contract is for creating a decentralized raffle
 * @dev This implements Chainlink VRF to ensure fairness
 */
contract Raffle is VRFConsumerBaseV2Plus {
    using VRFV2PlusClient for VRFV2PlusClient.RandomWordsRequest;

    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__TooEarly(
        uint256 currentTime, uint256 lastTimeStamp, uint256 balance, uint256 raffleStateUint, uint256 playersLength
    );

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState = RaffleState.OPEN;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestIdGenerated(uint256 indexed requestId);

    /**
     * @dev 构造函数
     * @param entranceFee 入场费
     * @param interval 开奖的时间间隔
     * @param vrfCoordinator VRF 的 coordinator
     * @param gasLane VRF 的 gas lane 作为 key hash
     * @param subscriptionId 订阅 id
     * @param callbackGasLimit 回调函数消耗的 gas limit
     */
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        uint256 subscriptionId
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimeStamp = block.timestamp;
    }

    /**
     * @dev 进入抽奖
     * 1. 检查入场费是否足够
     * 2. 检查开奖状态是否为 OPEN
     * 3. 将玩家添加到玩家列表中
     * 4. 发射事件
     * error Raffle__NotEnoughEthSent 入场费不足
     * error Raffle__RaffleNotOpen 开奖状态不对
     */
    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        // emit event
        emit RaffleEntered(msg.sender);
    }

    /**
     * @dev 检查是否需要开奖 Chainlink VRF
     * @return upkeepNeeded 是否需要开奖
     * @return callData 回调函数数据
     */
    function checkUpkeep(bytes calldata /* checkData */ )
        public
        view
        returns (bool upkeepNeeded, bytes memory callData)
    {
        bool timePassed = ((block.timestamp - s_lastTimeStamp) >= i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "");
    }

    /**
     * @dev 由 ChainLink automation 调用执行开奖。"perform"意味着执行或实施。
     * @param performData 执行数据
     */
    function performUpkeep(bytes calldata performData) external {
        (bool upkeepNeeded,) = checkUpkeep(performData);
        if (!upkeepNeeded) {
            revert Raffle__TooEarly(
                block.timestamp, s_lastTimeStamp, address(this).balance, uint256(s_raffleState), s_players.length
            );
        }
        uint256 requestId = pickWinner();
        emit RequestIdGenerated(requestId);
    }

    /**
     * @dev 开奖
     * @return requestId 请求 id
     */
    function pickWinner() private returns (uint256 requestId) {
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert Raffle__TooEarly(
                block.timestamp, s_lastTimeStamp, address(this).balance, uint256(s_raffleState), s_players.length
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        /**
         * @dev 请求随机数
         * @param keyHash is the gas lane key hash
         * @param subId is the subscription id
         * @param requestConfirmations ChainLine回应之前等待的确认数
         * @param callbackGasLimit 回调函数消耗的 gas limit
         * @param numWords 随机数个数
         * @param extraArgs is the extra arguments
         */
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                // 使用 native payment 支付 gas 比如 0.1 LINK
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
            )
        });
        requestId = s_vrfCoordinator.requestRandomWords(req);
    }

    /**
     * @dev 回调函数 由 VRFCoordinator 调用 fulfillRandomWords
     * @param randomWords 随机数 calldata 数组
     */
    function fulfillRandomWords(
        uint256,
        /* requestId */
        uint256[] calldata randomWords
    ) internal override {
        if (s_raffleState != RaffleState.CALCULATING) {
            revert Raffle__RaffleNotOpen();
        }

        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner; // 这里的 s_recentWinner 不是payable类型，所以需要使用 payable(s_recentWinner) 来赋值
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(recentWinner);

        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    /* Getter Functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getLastTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }
}
