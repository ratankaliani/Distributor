// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Raffle is Ownable, VRFConsumerBase {
    
    uint256 randomSeed; 
    // Result from Chainlink VRF
    uint256 public randomResult = 0;
    // Toggled when contract requests result from Chainlink VRF
    bool public raffleRun = false;

    constructor() VRFConsumerBase (
    _ChainlinkVRFCoordinator,
    _ChainlinkLINKToken
  ){}

    function generateWinners(uint numNFTs, uint totalShares) onlyOwner public returns (uint256[] memory) {
        uint256[] memory winnerNumbers = new uint256[](numNFTs);
        bool[] memory prevWinners = new bool[](totalShares); 
        for (uint256 i = 0; i < numNFTs; i++) {
            uint256 winner_index = requestRandomness(keyHash, fee) % totalShares;
            uint256 count = 0;
            while (prevWinners[winner_index] && count <= 10) {
                winner_index = requestRandomness(keyHash, fee) % totalShares;
                count++;
            }
            count = 0;
            prevWinners[winner_index] = true; 
            winnerNumbers[i] = winner_index; 
        }
        return winnerNumbers; 
    }
}