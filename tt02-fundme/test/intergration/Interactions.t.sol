// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMeFund, FundMeWithdraw} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant AMOUNT = 1e18;
    uint256 constant SUCCESS_FUND_AMOUNT = 6e14;
    uint256 constant FAIL_FUND_AMOUNT = 4e14;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, AMOUNT);
    }

    function test_fundMe() public {
        vm.prank(USER);
        FundMeFund fundMeFund = new FundMeFund();
        fundMeFund.fundMeFund(address(fundMe));

        FundMeWithdraw fundMeWithdraw = new FundMeWithdraw();
        fundMeWithdraw.fundMeWithdraw(address(fundMe));

        assertEq(address(fundMe).balance, 0);

        // address funder = fundMe.getFunder(0);
        // assertEq(funder, address(fundMeFund));
    }
}
