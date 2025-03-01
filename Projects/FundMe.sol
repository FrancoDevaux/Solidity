```sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

// Custom errors
error NotOwner();

contract FundMe{
    using PriceConverter for uint256;
    uint256 public constant MINIM_USD = 5e18; // 5 * (10 ** 18)

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;
    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIM_USD, "You need to spend more ETH!"); // 1e18 = 1 ETH
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        // Borramos la linea que estaba aca que era del codigo de 9)Constructor
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        //call ---> Podiamos haber usado transfer o send
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    modifier onlyOwner() {
        // Custom error (en los require se hace eso)
        if(msg.sender != i_owner) {revert NotOwner();}
        _;
    }

    //si se envía Ether a un contrato sin una función "receive" o "fallback", la transacción será rechazada y el Ether no se transferirá
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
```sol
