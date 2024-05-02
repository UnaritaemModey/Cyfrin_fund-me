//SPDX-License-Identifier: MIT

//write your pragma statement
pragma solidity ^0.8.19;
//import the contract and the Test scontract that forge-std gives
import {FundMe} from "src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; 
//Define the test contract and inherit Test
contract FundMeTest is Test{
FundMe fundMe;

address USER = makeAddr("USER"); // This creates an address to use to send transactions for testing purposes.
uint256  SEND_VALUE = 0.1 ether;
uint256 constant STARTING_BALANCE = 10 ether;
// the setUp function is the first to run and it is used to initialize conditions

modifier funded(){
   vm.prank(USER);
   fundMe.fund{value: STARTING_BALANCE}();
   _;

}

function setUp () external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();

    vm.deal(USER,STARTING_BALANCE); // This gives a test address some ether to enable it carry out transactions
     
  // fundMe = new FundMe( 0x694AA1769357215DE4FAC081bf1f309aDC325306);

}
  
// We are using this to test that number is equal to 2. We can also add console logs here for more clarity
 function testMinimumUsdIsFive() public view {
    assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
   
 } 

function testGetVersion() public view {
   uint256 version = fundMe.getVersion();
   assertEq(version,4);
}



function testFundFailsWithoutEnoughEth () public{
// A FOUNDRY CHEATCODE that is used to check if the next line fails
   vm.expectRevert();
   fundMe.fund();// fails because we didn't pass in some eth while calling this 

}


function testFundUpdatesFundedDataStructure () public{
   vm.prank(USER);
 fundMe.fund{value: SEND_VALUE}();

 uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
 assertEq(amountFunded, SEND_VALUE);

}


function testAddsFunderToArrayOfFunders() public{
   //Let the user carry out a fund transaction
  vm.prank(USER);
  fundMe.fund{value: SEND_VALUE}();

//from the function,get the address of the funder at index 0(person who just funded first)
address funderAddress = fundMe.getFunders(0);

//now compare it with the address of "USER"
assertEq(USER, funderAddress);

}

function testOnlyOwnerCanWithdraw () public funded{
  
   //We are testing the efficiency of the onlyOwner modifier in withdraw function, by using another address to call the withdraw function. This should fail and revert with an error
    vm.prank(USER);
   vm.expectRevert();
 
  fundMe.withdraw();

}

function testWithdrawWithASingleFunder () public funded{
   //Arrange
   uint256 startingOwnerBalance = fundMe.getOwner().balance;
   
   uint256 startingFundMeBalance = address(fundMe).balance;

   //Act
   vm.prank(fundMe.getOwner());
   fundMe.withdraw();


   ///Assert
   uint256 endingOwnerBalance = fundMe.getOwner().balance;
   uint256 endingFundMeBalance = address(fundMe).balance;
   assertEq(endingFundMeBalance, 0);
assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

}



function testWithdrawFromMultipleFunders() public funded {
   uint160 numberOfFunders = 10;
   uint160 startingFunderIndex = 1;

   for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){


hoax(address(i),  SEND_VALUE);   
  fundMe.fund{value: SEND_VALUE}();             }

  uint256 startingOwnerBalance = fundMe.getOwner().balance;
   uint256 startingFundMeBalance = address(fundMe).balance;

   vm.startPrank(fundMe.getOwner());
   fundMe.withdraw();
   vm.stopPrank();
  

  assert(address(fundMe).balance == 0);
assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);


}


function testWithdrawFromMultipleFundersCheaper() public funded {
   uint160 numberOfFunders = 10;
   uint160 startingFunderIndex = 1;

   for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){


hoax(address(i),  SEND_VALUE);   
  fundMe.fund{value: SEND_VALUE}();             }

  uint256 startingOwnerBalance = fundMe.getOwner().balance;
   uint256 startingFundMeBalance = address(fundMe).balance;

   vm.startPrank(fundMe.getOwner());
   fundMe.cheaperWithdraw();
   vm.stopPrank();
  

  assert(address(fundMe).balance == 0);
assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);

}
























































































































































































































































































































}