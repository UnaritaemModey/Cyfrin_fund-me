//SPDX-License-Identifier: MIT

//write your pragma statement
pragma solidity ^0.8.19;
//import the contract and the Test scontract that forge-std gives
import {FundMe} from "src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; 
import {FundFundMe} from "../../script/Interactions.s.sol";
import {WithdrawFundMe} from "../../script/Interactions.s.sol";
//Define the test contract and inherit Test
contract InteractionsTest is Test {

    FundMe fundMe;

address USER = makeAddr("USER"); // This creates an address to use to send transactions for testing purposes.
uint256  SEND_VALUE = 0.1 ether;
uint256 constant STARTING_BALANCE = 10 ether;
// the setUp function is the first to run and it is used to initialize conditions



function setUp () external {
    DeployFundMe deployFundMe = new DeployFundMe();

    fundMe = deployFundMe.run();

    vm.deal(USER,STARTING_BALANCE); // This gives a test address some ether to enable it carry out transactions
     
  // fundMe = new FundMe( 0x694AA1769357215DE4FAC081bf1f309aDC325306);

}

function testUserCanFundInteractions() public{
    FundFundMe fundFundMe = new FundFundMe( );
    
    fundFundMe.fundFundMe(address(fundMe));

 WithdrawFundMe withdrawFundMe = new WithdrawFundMe( );
    
    withdrawFundMe.withdrawFundMe(address(fundMe));
    
assert(address(fundMe).balance == 0);


}
























}



























