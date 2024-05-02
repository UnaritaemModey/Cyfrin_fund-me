//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import{MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/*
THIS IS USED IN THE DEPLOY SCRIPTS because of configuration purposes.
IT is a way of upgrading our deploy script and making it more robust and programmatic

//--It is better to do deployment/testing locally for as long as possible because using RPC URL from node providers can run up the bill from multiple requests.

--Mock contracts are deployed to local anvil and interacted with for duration of local tests.

-- HelperConfig.sol is used to configure . Deploy mocks when on local anvil chain.
--Keep track of addresses across different chains.

//-- Helper config is configured to deploy mocks if we are on local anvil chain, Otherwise use existing addresses on live networks.

--It provides functionality based on certain conditions so that things are done programmatically and not hardcoded.
--So that tests can run on either local chain,forked or real chain.

IF WE ARE ON SEPOLIA(FORKED) THERE IS A  FUNCTION THAT HAS CONFIGURATION FOR EVERYTHING WE NEED IN SEPOLIA. THERE IS ALSO ONE FOR ANVIL


*/

contract HelperConfig is Script{



uint8 public constant ETH_DECIMAL = 8;
int256 public constant INITIAL_PRICE = 2000e8;

struct NetworkConfig{
    address priceFeed;
}


NetworkConfig public activeNetworkConfig;
constructor(){
    //This  is so that contracts on whatever chain can use the corresponding config  based on current chain
    if(block.chainid == 11155111){
        activeNetworkConfig = getSepoliaEthConfig();
    }
    else{
       activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
}

//the configurations provided in case of Sepolia
function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
   NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
   return sepoliaConfig;

}


function getOrCreateAnvilEthConfig () public  returns (NetworkConfig memory){
    if (activeNetworkConfig.priceFeed != address(0)){
        return activeNetworkConfig;
    }
  

//Deploy Mocks(mock price feed) when we are on a local anvil chain. It is a fake contract for testing on anvil as opposed to the ones already for sepolia. so we have to create it for our local anvil.
vm.startBroadcast();
MockV3Aggregator mockPriceFeed = new MockV3Aggregator(ETH_DECIMAL, INITIAL_PRICE);
vm.stopBroadcast();

//address of our mock price ffed
NetworkConfig memory anvilConfig = NetworkConfig({priceFeed:address(mockPriceFeed)});
return anvilConfig;

}



}