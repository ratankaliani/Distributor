// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// TO DO: should the contract be abstract? 
contract Raffle is Ownable, VRFConsumerBase {

    // Chainlink keyHash
    bytes32 internal immutable keyHash;
    // Chainlink fee
    uint256 internal immutable fee;
    // Struct for 
    struct UserRaffleInfo {
        uint start; 
        uint end; 
    }
    // mapping of struct for which 
    mapping (address => UserRaffleInfo) addressToRaffles; 

    mapping (address => uint) addressToNumNFTs; 
    
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
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        // Store random number as randomResult
        randomResult = randomness;
    }

    /**
    * Updates the global variable addressToNumNFTs so that addressToNumNFTs[user] represents the 
      total number of NFTs that user can mint. 
    * @param shares: shares[i] represents the number of shares for the user at addresses[i]. 
     */
    function generateWinners(uint num_NFTs, uint total_shares, address[] memory addresses, uint[] memory shares) public {        
        // TO DO: change how number of raffle tickets are calculated. 
        uint num_tickets = num_NFTs*2; 

        // raffle_tickets[i] = raffle_ticket.wonNFT ? 1 : 0; 
        uint[] memory raffle_tickets = new uint[](num_tickets); 

        // curr: represents current starting index for each user's range of raffle tickets. 
        uint curr = 0; 
        for (uint i = 0; i < addresses.length; i++) {
            address a = addresses[i]; 
            // a_shares: represents number of a's shares
            uint user_shares = shares[i]; // can also just use a getter function from Pool.sol to find adressToShares[address] 
            
            // tickets: num of raffle tickets user receives based on their number of shares 
            uint tickets = getNumberOfTickets(user_shares, total_shares, num_tickets); // create function
            
            /* for ex. If user a will receive 20 tickets, and 50 raffle tickets have already been 
               distributed ==> (curr, curr+tickets) = (50, 70) */
            addressToRaffles[a] = UserRaffleInfo(curr, curr+tickets); 
            curr += tickets; 
        }

        // finds winning indices 
        for (uint i = 0; i < num_NFTs; i++) {
            // update randomResult through chainlink
            requestRandomness(keyHash, fee); 
            uint256 winner_index = randomResult % num_tickets;

            // if raffle ticket has not already won, 
            // update number of NFTs that the winning address can mint. 
            if (raffle_tickets[winner_index] != 1) { 
                address a = indexToAddress(winner_index, addresses); 
                addressToNumNFTs[a] += 1; 
            }
            // indicate that the raffle ticket has won 
            raffle_tickets[winner_index] = 1; 
        } 

    }

    // find address of user with the winning index in their range of tickets 
    function indexToAddress(uint winner_index, address[] memory addresses) public view returns (address winnerAddress) {
        for (uint i = 0; i < addresses.length; i++) {
            address a = addresses[i]; 
            uint start = addressToRaffles[a].start; 
            uint end = addressToRaffles[a].end;
            if (winner_index >= start || winner_index < end) {
                return a; 
            } 
        }
        // need to add default address to return in case of error
    }

    /**
    Returns number of raffle tickets that user with x_shares number of shares receives */
    function getNumberOfTickets(uint x_shares, uint total_shares, uint num_tickets) internal pure returns (uint userTickets) {
        return x_shares / total_shares * num_tickets; 
    }

    // function generateWinners(uint numNFTs, uint totalShares) onlyOwner public returns (uint256[] memory) {
    //     require (raffleRun == false, "You cannot generate winners on a already completed raffle.");
    //     raffleRun = true;
    //     uint256[] memory winnerNumbers = new uint256[](numNFTs);
    //     bool[] memory prevWinners = new bool[](totalShares); 
    //     for (uint256 i = 0; i < numNFTs; i++) {
    //         requestRandomness(keyHash, fee);
    //         uint256 winner_index = randomResult % totalShares;
    //         uint256 count = 0;
    //         while (prevWinners[winner_index] && count <= 10) {
    //             requestRandomness(keyHash, fee);
    //             winner_index = randomResult % totalShares;
    //             count++;
    //         }
    //         count = 0;
    //         prevWinners[winner_index] = true; 
    //         winnerNumbers[i] = winner_index; 
    //     }
    //     return winnerNumbers; 
    // }
}