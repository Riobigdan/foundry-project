// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant AMOUNT = 1e18;
    uint256 constant SUCCESS_FUND_AMOUNT = 6e14;
    uint256 constant FAIL_FUND_AMOUNT = 4e14;
    uint256 constant GAS_PRICE = 1;

    
    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, AMOUNT);
    }

    // test by mock contract
    function test_owner_is_msgSender() external view {
        assertEq(fundMe.getOwner(), msg.sender);
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
        fundMe.fund{value: FAIL_FUND_AMOUNT}();  // 1 wei
    }
    
    function test_fund_update_addressToAmountFunded() external {
        vm.prank(USER);  // 将USER设置为msg.sender
        fundMe.fund{value: SUCCESS_FUND_AMOUNT}(); 
        assertEq(fundMe.getAddressToAmountFunded(USER), SUCCESS_FUND_AMOUNT);
    }

    function test_fund_update_funders() external {
        vm.prank(USER);
        fundMe.fund{value: SUCCESS_FUND_AMOUNT}();
        assertEq(fundMe.getFunder(0), USER);
    }

    function test_onlyOwner() external funded {
        vm.expectRevert();
        fundMe.withDraw();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SUCCESS_FUND_AMOUNT}();
        _;
    }

    function test_withDraw_with_one_funder() external funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withDraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }

    function test_withDraw_with_multiple_funders() external {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        uint256 amountToFund = 0;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SUCCESS_FUND_AMOUNT);
            fundMe.fund{value: SUCCESS_FUND_AMOUNT}();
            amountToFund += SUCCESS_FUND_AMOUNT;
        }

        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasBefore = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withDraw();
        uint256 gasAfter = gasleft();
        uint256 gasUsed = (gasBefore - gasAfter) * GAS_PRICE;
        console2.log("gas used: ", gasUsed);
        console2.log("gas price: ", GAS_PRICE);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingOwnerBalance - startingOwnerBalance, amountToFund);
        assertEq(endingFundMeBalance, 0);
    }
}