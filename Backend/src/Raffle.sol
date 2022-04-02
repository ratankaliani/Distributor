// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Raffle is Ownable, VRFConsumerBase {

    // Chainlink keyHash
    bytes32 internal immutable keyHash;
    // Chainlink fee
    uint256 internal immutable fee;
    // Struct for 
    struct UserRaffleInfo {
        uint start; 
        uint end; 
        uint numNFTs; 
    }
    // mapping of struct for which 
    mapping (address => UserRaffleInfo) addressToRaffles; 
    
    // NFT owner
    address public immutable owner;

    uint256 public randomResult = 0;

    // Toggled when contract requests result from Chainlink VRF
    bool public raffleRun = false;

    constructor(
        address _owner,
        bytes32 _ChainlinkKeyHash,
        uint256 _ChainlinkFee,
        address _ChainlinkVRFCoordinator,
        address _ChainlinkLINKToken
    ) VRFConsumerBase (
        _ChainlinkVRFCoordinator,
        _ChainlinkLINKToken
  ){
        fee = _ChainlinkFee;
        keyHash = _ChainlinkKeyHash;
        owner = _owner;
  }

    function fulfillRandomness(uint256 requestId, uint256 randomness) internal override {
        // Store random number as randomResult
        randomResult = randomness;
    }

    function generateWinners(uint numNFTs, uint totalShares, address[] memory addresses, uint[] memory shares) public {
        // raffle_tickets[i] = raffle tickets for address @ addresses[i]
        uint num_tickets = numNFTs*2; 
        uint[] memory raffle_tickets = new uint[](num_tickets); 

        uint curr = 0; 
        for (uint i = 0; i < addresses.length; i++) {
            address a = addresses[i]; 
            uint a_shares = shares[i]; // can also just use a getter function from Pool.sol to find adressToShares[address] 
            uint tickets = getNumberOfTickets(a, a_shares); // create function
            
            addressToRaffles[a] = UserRaffleInfo(curr, curr+tickets, 0); 
        }

        for (uint i = 0; i < numNFTs; i++) {
            requestRandomness(keyHash, fee); 
            uint256 winner = randomResult % num_tickets;
            raffle_tickets[winner] = 1; 
        }
        

    }

    function getNumberOfTickets(address a, uint shares) internal returns (uint) {
        return 0; // CHANGE 
    }

    function generateWinners(uint numNFTs, uint totalShares) onlyOwner public returns (uint256[] memory) {
        require (raffleRun == false, "You cannot generate winners on a already completed raffle.");
        raffleRun = true;
        uint256[] memory winnerNumbers = new uint256[](numNFTs);
        bool[] memory prevWinners = new bool[](totalShares); 
        for (uint256 i = 0; i < numNFTs; i++) {
            requestRandomness(keyHash, fee);
            uint256 winner_index = randomResult % totalShares;
            uint256 count = 0;
            while (prevWinners[winner_index] && count <= 10) {
                requestRandomness(keyHash, fee);
                winner_index = randomResult % totalShares;
                count++;
            }
            count = 0;
            prevWinners[winner_index] = true; 
            winnerNumbers[i] = winner_index; 
        }
        return winnerNumbers; 
    }
}