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

    // test by mock contract
    function test_owner_is_msgSender() external view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    //初始化价格 1ETH = 2000 USD
    function test_getPrice() external view {
        uint256 price = fundMe.getPrice();
        assertEq(price, 2000e8);
    }

    function test_getMinUSD() external view {
        assertEq(fundMe.getMinimumUSD(), 1);
    }

    function test_getMinETH() external view {
        assertEq(fundMe.usdToETH(1), 50000);
    }

    function test_getMinWei() external view {
        assertEq(fundMe.usdToETH(1)*1e18, 5*1e22);
    }

    function test_fund_faild_when_not_enough_eth() external {
        vm.expectRevert();
        fundMe.fund{value: 4e22}();  // 1 wei

    }
}