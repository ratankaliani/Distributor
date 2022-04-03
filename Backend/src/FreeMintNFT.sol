// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract FreeMintNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 totalNFTs;

    constructor(uint256 _totalNFTs) ERC721("FreeMintNFT Example", "FMN") {
        totalNFTs = _totalNFTs;
    }

    // TODO: ADD onlyOwner modifier
    function mintNFT(address receiver, string memory baseURI, string memory postFixURI) external returns (uint256) {
        require(_tokenIds.current() < totalNFTs, "All NFTs have been minted!");

        _tokenIds.increment();

        uint256 newNftTokenId = _tokenIds.current();
        _mint(receiver, newNftTokenId);

        string memory tokenURI = string(abi.encodePacked(baseURI, Strings.toString(newNftTokenId), postFixURI)); 
        _setTokenURI(newNftTokenId, tokenURI);
        return newNftTokenId;     
    }
}