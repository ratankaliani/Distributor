// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import {BaseTest, console} from "./base/BaseTest.sol";
import {FreeMintPool} from "../FreeMintPool.sol";
import {FreeMintNFT} from "../FreeMintNFT.sol";
import {ILendingPool} from "../interfaces/ILendingPool.sol";
import {console} from "./utils/console.sol";

contract PoolTest is BaseTest {
    FreeMintPool private fmpool;
    ILendingPool public immutable aaveLendPool =
        ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    uint public numNFTs;
    string public baseURI;
    string public postFixURI;

    function setUp() public {
        uint poolID = 1;
        address organization = 0xcf0Ef02C51438C821246f2e6ADe50e0F1CB0f385;
        address lendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
        uint timeToClose = 7 days;
        uint bondPeriod = 5 days;
        baseURI = "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-";
        postFixURI = ".jpeg"; 
        numNFTs = 10;
        fmpool = new FreeMintPool(poolID, organization, lendingPool, timeToClose, bondPeriod, baseURI, postFixURI, numNFTs);
    }

    function testCheckNFTs() public {
        FreeMintNFT freeMintNFTContract = new FreeMintNFT(numNFTs);
        address ratan = 0xcf0Ef02C51438C821246f2e6ADe50e0F1CB0f385;
        freeMintNFTContract.mintNFT(ratan, baseURI, postFixURI);
        assertTrue(freeMintNFTContract.ownerOf(1) == ratan);
        string memory uri = freeMintNFTContract.tokenURI(1);
        string memory expectedURI = "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-1.jpeg";
        assertTrue((keccak256(abi.encodePacked((uri))) == keccak256(abi.encodePacked((expectedURI)))));
    }

    function testState() public {
        console.log(fmpool.getState());
        vm.warp(7 days);
        console.log(fmpool.getState());
        console.log(fmpool.getCloseTime());
        vm.warp(12 days);
        console.log(fmpool.getState());
        console.log(fmpool.getEndBondingPeriod());
        vm.warp(22 days);
        console.log(fmpool.getState());
        console.log("Hello world!");
        assertTrue(true);
    }

    function testCheckNFTsEz() public {
        FreeMintNFT freeMintNFTContract = new FreeMintNFT(numNFTs);
        address ratan = 0xcf0Ef02C51438C821246f2e6ADe50e0F1CB0f385;
        freeMintNFTContract.mintNFT(ratan, baseURI, postFixURI);
        assertTrue(freeMintNFTContract.ownerOf(1) == ratan);
        string memory uri = freeMintNFTContract.tokenURI(1);
        string memory expectedURI = "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-1.jpeg";
        assertTrue((keccak256(abi.encodePacked((uri))) == keccak256(abi.encodePacked((expectedURI)))));
    }
}
