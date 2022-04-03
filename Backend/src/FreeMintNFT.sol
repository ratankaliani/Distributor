// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract FreeMintNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 totalNFTs;

    constructor(uint256 _totalNFTs) ERC721("FreeMintNFT Example", "FMN") {
        totalNFTs = _totalNFTs;
    }

    function mintNft(address receiver, string memory tokenURI) external onlyOwner returns (uint256) {
        require(_tokenIds.current() < totalNFTs, "All NFTs have been minted!");

        _tokenIds.increment();

        uint256 newNftTokenId = _tokenIds.current();
        _mint(receiver, newNftTokenId);
        _setTokenURI(newNftTokenId, tokenURI);

        return newNftTokenId;
    }
}