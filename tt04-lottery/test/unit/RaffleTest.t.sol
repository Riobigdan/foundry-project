// SPDX-License-Identifier: MIT
/**
@dev Layout of contract
 version
 imports
 errors
 interfaces, libraries, contracts
 Type declarations
 State variables
 Events
 Modifiers
 Functions
*/

pragma solidity ^0.8.20;

import {Raffle} from "src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
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
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            callbackGasLimit,
            subscriptionId
        ) = (
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
}
