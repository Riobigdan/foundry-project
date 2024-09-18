// SPDX-License-Identifier: MIT
// Fund and Withdraw

pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundMeFund is Script {
    uint256 constant SUCCESS_FUND_AMOUNT = 6e14;
    function fundMeFund(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // 在测试中，使用vm.startBroadcast()和vm.stopBroadcast()来管理广播状态
        FundMe(payable(mostRecentlyDeployed)).fund{
            value: SUCCESS_FUND_AMOUNT
        }();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SUCCESS_FUND_AMOUNT);
    }
    function run() external {
        // fund 在我最近一次部署的合约
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundMeFund(mostRecentlyDeployed);
    }
}

contract FundMeWithdraw is Script {
    function fundMeWithdraw(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withDraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundMeWithdraw(mostRecentlyDeployed);
    }
}
