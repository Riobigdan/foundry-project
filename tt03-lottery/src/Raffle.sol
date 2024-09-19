// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Raffle
 * @author Rio
 * @notice This contract is for creating a decentralized raffle
 * @dev This implements Chainlink VRF to ensure fairness
 */

contract Raffle {
    /* Errors */
    error Raffle__NotEnoughEthSent();

    uint256 private immutable i_entranceFee;
    // @dev 开奖的时间间隔
    uint256 private immutable i_interval;
    address payable[] private s_players;

    /* Events */
    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        // emit event 
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        // Generate a random number

    }


    /* Getter Functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}