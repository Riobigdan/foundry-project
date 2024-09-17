// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {PriceLibrary} from "./PriceLibrary.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    error NotOwner();
    using PriceLibrary for uint256; 
    uint256 public constant MINIMUM_USD = 1;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    uint256 public totalFunds;
    address public immutable i_owner;
    AggregatorV3Interface public a_priceFeed;

    constructor(address priceFeed){
        i_owner = msg.sender;
        a_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getMinimumUSD() public pure returns (uint256){
        return MINIMUM_USD;
    }

    function fund() public payable{
        require(PriceLibrary.getConversionRate(msg.value, a_priceFeed) >= MINIMUM_USD, "Not enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }
    function withDraw() public onlyOwner{
        for(uint256 i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

    function getPrice() public view returns (uint256){
        return PriceLibrary.getPrice(a_priceFeed);
    }

    modifier onlyOwner(){
        if(msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }

    receive() external payable{
        fund();
    }

    fallback() external payable{
        fund();
    }
}

