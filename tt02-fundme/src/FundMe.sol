// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {PriceLibrary} from "./PriceLibrary.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";
import {console2} from "forge-std/console2.sol";

contract FundMe {
    using PriceLibrary for uint256; 
    error NotOwner();
    AggregatorV3Interface public a_priceFeed;
    uint256 public constant MINIMUM_USD = 1;
    uint256 public s_totalFunds;
    address[] public s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;

    constructor(address priceFeed){
        i_owner = msg.sender;
        a_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getOwner() public view returns (address){
        return i_owner;
    }

    function getMinimumUSD() public pure returns (uint256){
        return MINIMUM_USD;
    }

    function usdToETH(uint256 a_usdAmount) public view returns (uint256){
        uint256 amountToUse = a_usdAmount == 0 ? MINIMUM_USD : a_usdAmount;
        return PriceLibrary.usdToEth(amountToUse, a_priceFeed);
    }

    function usdToWei(uint256 a_usdAmount) public view returns (uint256){
    }

    function fund() public payable{
        uint256 minAmount = usdToETH(MINIMUM_USD)*1e10;  //注意这个1e10，因为priceFeed返回的是8位小数
        require(msg.value >= minAmount, "Not enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_totalFunds += msg.value;
    }

    function withDraw() public onlyOwner{
        for(uint256 i = 0; i < s_funders.length; i++){
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Failed to send ETH");
    }

    function withdrawCheaper() public onlyOwner{
        uint256 fundersCount = s_funders.length;
        for(uint256 i = 0; i < fundersCount; i++){
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Failed to send ETH");
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

    function getAddressToAmountFunded(address a_funderAddress) public view returns (uint256){
        return s_addressToAmountFunded[a_funderAddress];
    }

    function getFunder(uint256 index) public view returns (address){
        return s_funders[index];
    }
}

