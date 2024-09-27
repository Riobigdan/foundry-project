// SPDX-Licencse-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {ZeppelinToken} from "src/ZeppelinToken.sol";
import {DeployZeppelinToken} from "script/DeployZeppelinToken.s.sol";

contract ZeppelinTokenTest is Test {
    uint256 public constant INITIAL_SUPPLY = 1000;
    DeployZeppelinToken public deployer;
    ZeppelinToken public zeppelinToken;

    address zhang = makeAddr("zhang");
    address wang = makeAddr("wang");

    function setUp() public {
        deployer = new DeployZeppelinToken();
        zeppelinToken = deployer.run();

        vm.prank(msg.sender);
        zeppelinToken.transfer(zhang, INITIAL_SUPPLY);
    }

    function test_ZhangBalance() public view {
        assertEq(zeppelinToken.balanceOf(zhang), INITIAL_SUPPLY);
    }

    function test_allowance() public {
        uint256 initialAllowance = 1000;
        // 张三批准王五的账户中转移1000个代币
        vm.prank(zhang);
        zeppelinToken.approve(wang, initialAllowance);

        // 王五从张三的账户中转移100个代币
        vm.prank(wang);
        zeppelinToken.transferFrom(zhang, wang, 100);

        // 张三的账户中剩余的代币数量
        assertEq(zeppelinToken.allowance(zhang, wang), initialAllowance - 100);
        assertEq(zeppelinToken.balanceOf(wang), 100);
    }

    function test_transfer() public {
        vm.prank(zhang);
        zeppelinToken.transfer(wang, 100);
        assertEq(zeppelinToken.balanceOf(wang), 100);
        assertEq(zeppelinToken.balanceOf(zhang), INITIAL_SUPPLY - 100);
    }

    function test_transferFrom() public {
        uint256 initialAllowance = 1000;

        vm.prank(zhang);
        zeppelinToken.approve(wang, initialAllowance);

        vm.prank(wang);
        zeppelinToken.transferFrom(zhang, wang, 100);
        assertEq(zeppelinToken.balanceOf(wang), 100);
        assertEq(zeppelinToken.balanceOf(zhang), INITIAL_SUPPLY - 100);
        assertEq(zeppelinToken.allowance(zhang, wang), initialAllowance - 100);
    }
}
