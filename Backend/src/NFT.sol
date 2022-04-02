// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721URIStorage {

    address public immutable _owner;

    // Counters to keep track of share range
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    address public immutable vaultAddress;

    mapping(address => NFTMetaData[]) public ownershipRecord;

    struct NFTMetaData{
        uint256 tokenId;
        uint256 timeStamp;
        uint256 price; 
        string tokenURI;
        address payable seller; 
        address payable owner; 
    }

    constructor(address _vaultAddress) ERC721("Decentralized Crowdfunding NFTs", "DCNFT") {
        vaultAddress = _vaultAddress;
    }

    function createToken(string memory tokenURI, uint256 winningNum, uint256 price) public returns (uint256) {
        uint256[] memory addressRange = vaultAddress.getAddressRange(msg.sender);
        require (addressRange[0] <= winningNum && addressRange[1] > winningNum);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        ownershipRecord[msg.sender].push(NFTMetaData(newItemId, block.timestamp, tokenURI, msg.sender, msg.sender, price));
        return newItemId;
    }

    function fetchMyNFTs(address owner) external returns (NFTMetaData[] memory) {
        return ownershipRecord[owner]; 
    }

}

// mapping (tokenId => metaData) created first by NFT creators <<< 
    // TASKS: 
    // 1. create a function for NFT creators to enter metaData and push to the mapping 
// mapping (owner => tokenIds[]) created after minting, shows proof of ownership