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
    uint256 public constant STARTING_USER_BALANCE = 1 ether;

    Raffle raffle;
    HelperConfig helperConfig;

    address public PLAYER = makeAddr("player");

    function setUp() public {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
    }
}
