// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BasicNftTest is Test, IERC721Receiver {
    BasicNft basicNft;
    DeployBasicNft deployer;

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }
    /**
     * @dev 实现IERC721Receiver接口的onERC721Received函数
     * @return 返回值
     */

    function onERC721Received(address, /*operator*/ address, /*from*/ uint256, /*tokenId*/ bytes calldata /*data*/ )
        external
        pure
        override
        returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    function test_mintNft() public {
        basicNft.mintNft("https://www.google.com");
        assertEq(basicNft.tokenURI(0), "https://www.google.com");
    }

    function test_transferNft() public {
        basicNft.mintNft("https://www.google.com");
        basicNft.transferFrom(address(this), address(1), 0);
        assertEq(basicNft.ownerOf(0), address(1));
    }

    function test_nameAndSymbol() public view {
        assertEq(basicNft.name(), "Dadan");
        assertEq(basicNft.symbol(), "DADAN");
    }
}
