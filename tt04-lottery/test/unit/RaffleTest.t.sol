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
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

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
}
