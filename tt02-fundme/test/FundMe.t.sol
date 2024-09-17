// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    
    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function test_getMinimumUSD() external view {
        assertEq(fundMe.getMinimumUSD(), 1);
    }

    // test by mock contract
    function test_owner_is_msgSender() external view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // test by mock contract
    function test_getPrice() external view {
        uint256 price = fundMe.getPrice();
        console2.log(price);
    }
}