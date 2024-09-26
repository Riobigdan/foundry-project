// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Modulo} from "src/Modulo.sol";

contract ModuloTest is Test {
    Modulo modulo;

    function setUp() public {
        modulo = new Modulo();
    }

    function test_modulo() public view {
        assertEq(modulo.modulo(10, 3), 1);
        assertEq(modulo.modulo2(10), 0);
        assertEq(modulo.modulo10(11), 1);
    }
}
