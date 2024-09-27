// SPDX-License-Identifier: MIT
/**
 * @dev Layout of contract
 *  version
 *  imports
 *  errors
 *  interfaces, libraries, contracts
 *  Type declarations
 *  State variables
 *  Events
 *  Modifiers
 *  Functions
 */
pragma solidity ^0.8.19;

import {Raffle} from "src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    Raffle raffle;
    HelperConfig helperConfig;
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 1 ether;

    function setUp() public {
        vm.deal(PLAYER, STARTING_USER_BALANCE);
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        (entranceFee, interval, vrfCoordinator, gasLane, callbackGasLimit, subscriptionId) = (
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.callbackGasLimit,
            config.subscriptionId
        );
    }

    function test_raffleInitialState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    /*/////////////////////////////////////////////////////////////////////
                            Enter Raffle
    /////////////////////////////////////////////////////////////////////*/
    function test_enterRaffleRevertWhenNotEnoughEth() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle{value: entranceFee - 1}();
    }

    function test_RafflePlayersArrayChangesWhenEnter() public {
        vm.prank(PLAYER);

        raffle.enterRaffle{value: entranceFee + 1}();
        address player = raffle.getPlayer(0);
        assertEq(player, PLAYER);
    }

    function test_RaffleEnteredEventIsEmitedWhenEnter() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, true, false, false, address(raffle)); // 最多 4 个 index 事件 一个就代表一个 true
        emit Raffle.RaffleEntered(PLAYER);
        // emit Raffle.RaffleEntered(address(raffle)); // 这里会报错 因为 emit 的参数类型不对 期望的是 player 的地址
        raffle.enterRaffle{value: entranceFee + 1}();
    }

    function test_notAllowPlayerEnterWhenRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee + 1}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // 执行抽奖维护操作，此时抽奖状态应变为"计算中"
        raffle.performUpkeep("");

        // 再次进入抽奖，此时抽奖状态应为"计算中"，所以会报错
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        raffle.enterRaffle{value: entranceFee + 1}();
    }
    /*///////////////////////////////////////////////////////
                                CheckUpkeep
    ///////////////////////////////////////////////////////*/

    function test_checkUpKeepReturnsFalseIfItHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upKeepNeeded,) = raffle.checkUpkeep("");

        assertEq(upKeepNeeded, false);
    }

    function test_checkUpKeepReturnsFalseIfRaffleIsNotOpen() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee + 1}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        (bool upKeepNeeded,) = raffle.checkUpkeep("");
        assertEq(upKeepNeeded, false);
    }
    /*///////////////////////////////////////////////////////
                            PerformUpkeep
    ///////////////////////////////////////////////////////*/

    function test_PerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee + 1}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");
    }

    function test_PerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        // Arrange
        uint256 currentBalance = address(raffle).balance;
        uint256 numPlayers = 0;
        Raffle.RaffleState state = raffle.getRaffleState();

        // Act
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        currentBalance = currentBalance + entranceFee;
        numPlayers = numPlayers + 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__TooEarly.selector,
                block.timestamp, // currentTime
                raffle.getLastTimeStamp(), // lastTimeStamp
                currentBalance, // balance
                uint256(state), // raffleState
                numPlayers // playersLength
            )
        );

        raffle.performUpkeep("");
    }

    function test_PerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEnteredAndTimePassed {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        // 确保至少有一个日志条目
        require(entries.length > 0, "No logs emitted");

        bytes32 requestId = entries[1].topics[1];
        Raffle.RaffleState state = raffle.getRaffleState();
        assertEq(uint256(state), uint256(Raffle.RaffleState.CALCULATING));
        assertEq(uint256(requestId) > 0, true);

        // vm.expectEmit(true, false, false, false, address(raffle));
        // emit Raffle.RequestIdGenerated(uint256(requestId));
    }

    /**
     * @dev 测试 fulfillRandomWords 只能由 coordinator 调用
     * 这里需要借助 Mock 合约 VRFCoordinatorV2_5Mock 来测试
     * 因为 fulfillRandomWords 是 internal 函数，无法直接在测试中调用
     * Fuzz test
     */
    function test_FulfillRandomWordsCanOnlyBeCalledByCoordinator(uint256 randomNumber)
        public
        raffleEnteredAndTimePassed
    {
        // 借助 Mock 调用 fulfillRandomWords 函数
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomNumber, address(raffle));
    }

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }
}
