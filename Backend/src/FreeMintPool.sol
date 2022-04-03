// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;

import "../lib/solmate/src/tokens/ERC20.sol";
import "./utils/floating_point/Exponential.sol";
import "./interfaces/ILendingPool.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import "./FreeMintNFT.sol";

// interface FreeMintNFT is ERC721URIStorage, Ownable {
//     function mintNFT(address receiver, string memory tokenURI) returns (uint256);
// }

contract FreeMintPool is Exponential {
    
    struct UserData {
        uint neib;
        uint shares;
    }

    uint poolID;
    uint closeTime;
    uint bondTime;
    uint8 initialized = 0;
    uint8 finalized = 0;
    uint timeStart;

    // Asset addresses are ** aToken ** addresses
    mapping (address => uint) public totalShares;

    // Asset addresses after finalize is called. 
    mapping (address => uint) public totalSharesFinalized; 

    // User address -> aToken address -> UserData
    mapping (address => mapping (address => UserData)) userData; 

    // User addresses
    address[] public users;
    
    // Exp fractionToWithdraw;
    address public organization;
    address public lendingPool;
    uint shareDecimals = 10 ** 12;

    // NFT contract
    FreeMintNFT public freeMintNFTContract; 
    string baseURI; 
    string postFixURI; 

    uint256 numNFTs;

    event DepositMade(address user, address asset, address lpAsset, uint amount);
    event UserWithdrawMade(address user, address asset, address lpAsset, uint amount);
    event WithdrawToPool(address asset, uint amount);


    /**
    @param _poolID: i for the ith pool that is initialized
    @param _organization  organization to withdraw to
    @param _lendingPool lending pool address aave
    @param _timeToClose time allocated for close period
    @param _bondPeriod: time allotted for the bonding period 
    @param _baseURI: base URI for the given NFT contract ()
    @param _postFixURI: post URI for the given NFT contract (.jpeg)
    @param _numNFTs: available supply of NFTs to be minted for specified NFT contract 
     */
    constructor (uint _poolID, address _organization, address _lendingPool, uint _timeToClose, uint _bondPeriod, string memory _baseURI, string memory _postFixURI, uint256 _numNFTs) {
        poolID = _poolID;
        organization = _organization;
        lendingPool = _lendingPool;
        closeTime = _timeToClose;
        bondTime = _bondPeriod;
        baseURI = _baseURI; 
        postFixURI = _postFixURI; 
        freeMintNFTContract = new FreeMintNFT(_numNFTs);
        numNFTs = _numNFTs;
    }

    function getID() public view returns (uint) {
        return poolID;
     }

    /**
     * Allow a user to deposit tokens into the protocol
     * NOTE: Users must call _erc20Contract.approve() before calling this function
     * since we this contract will be using their tokens to deposit into aave
     * NOTE: We force all decimals to be 18 regardless of asset
     * @param asset the ERC contract for the underlying token
     * @param lpAsset the ERC contract for the liquidity token
     * @param amount the amount of token supplied, multipled by 10^18
     */
    function deposit(address asset, address lpAsset, uint amount) public {
        if (initialized == 0) {
            closeTime = block.timestamp + closeTime;
            bondTime = closeTime + bondTime;
            initialized = 1;
        }
        require(block.timestamp < closeTime, "Time to close passed");

        // console.log(totalShares[lpAsset]);
        // Check if the user has previously deposited
        if (totalShares[lpAsset] == 0){
            return depositInitial(asset, lpAsset, amount);
        }
        // console.log(totalShares[lpAsset]);
        // Convert amount to shares
        uint shares = convertToShares(lpAsset, amount);

        // Calculate how much interest has been earned so far
        uint interestSoFar = calculateInterest(lpAsset, userData[msg.sender][lpAsset].neib, userData[msg.sender][lpAsset].shares);

        // Issue new shares at the current rate
        userData[msg.sender][lpAsset].shares += shares;
        totalShares[lpAsset] += shares;

        // Temporarily move user's assets into the Pool contract 
        IERC20 assetContract = IERC20(asset);
        assetContract.transferFrom(msg.sender, address(this), amount);

        // Deposit assets into Aave's lending pool and receive tokens
        ILendingPool pool = ILendingPool(lendingPool);
        assetContract.approve(lendingPool, amount);
        pool.deposit(asset, amount, address(this), 0);

        // Calculate new neib based on new share proportion and previously  earned interest\
        userData[msg.sender][lpAsset].neib = convertToAsset(lpAsset, userData[msg.sender][lpAsset].shares) - interestSoFar;

        emit DepositMade(msg.sender, asset, lpAsset, amount);
    }

    function depositInitial(address asset, address lpAsset, uint amount) private {

        // Temporarily move user's assets into the Pool contract 
        IERC20 assetContract = IERC20(asset);
        assetContract.transferFrom(msg.sender, address(this), amount);

        // Deposit assets into Aave's lending pool and receive tokens
        ILendingPool pool = ILendingPool(lendingPool);
        assetContract.approve(lendingPool, amount);
        pool.deposit(asset, amount, address(this), 0);

        // Issue shares at a rate of one share per asset
        userData[msg.sender][lpAsset].shares = amount;
        userData[msg.sender][lpAsset].neib = amount;
        // Add users to users array
        users.push(msg.sender);
        totalShares[lpAsset] = amount;
        emit DepositMade(msg.sender, asset, lpAsset, amount);
    }
    
    /**
     * Allow a user to withdraw tokens out of the protocol, splitting interest acccordingly
     * NOTE: 
     * @param asset the ERC contract for the underlying token
     * @param lpAsset the ERC contract for the liquidity token
     */
    function withdraw(address asset, address lpAsset) public returns (uint256[] memory tokenIds){
        require(block.timestamp >= bondTime, "Bond time not completed!");

        if (finalized == 0) {
            finalize(lpAsset);
        }

        // Convert asset amount to shares 
        uint shares = userData[msg.sender][lpAsset].shares;

        // Total Assets for User
        uint amount = convertToAsset(lpAsset, shares);

        // Require that the user has enough shares to withdraw
        require(userData[msg.sender][lpAsset].shares >= shares, "Not enough tokens");

        // Calculate interest and pool interest cut
        uint interest = calculateInterest(lpAsset, userData[msg.sender][lpAsset].neib, shares);

        // Withdraw the user's cut and the pool's cut
        ILendingPool pool = ILendingPool(lendingPool);
        pool.withdraw(asset, amount - interest, msg.sender);
        if (interest > 0) {
            pool.withdraw(asset, interest, address(this));
            emit WithdrawToPool(asset, interest);
        }

        // Conduct raffle & mint NFTs
        tokenIds = userRaffle(shares, totalSharesFinalized[lpAsset]);

        // Update userData based on new shares 
        uint oldShares = userData[msg.sender][lpAsset].shares;
        userData[msg.sender][lpAsset].shares -= shares;
        userData[msg.sender][lpAsset].neib = userData[msg.sender][lpAsset].neib * userData[msg.sender][lpAsset].shares / oldShares;
        totalShares[lpAsset] -= shares;

        

        emit UserWithdrawMade(msg.sender, asset, lpAsset, amount);
        
        return tokenIds;
    }


    /**
     * RAFFLE CONTRACT STUFF
     * 
     */
    function userRaffle(uint userShares, uint totalSharesForAsset) public returns (uint[] memory) {
        uint numTickets = Math.ceilDiv(userShares, totalSharesForAsset) * 100 * numNFTs; 
        uint count = 0; 
        for (uint i = 0; i < numTickets; i++) {
            uint randNum = generateRandom(i); 
            uint value = randNum % (100 * numNFTs);
            if (value < numNFTs) {
                count ++; 
            }
        }

        uint[] memory tokenIds = new uint[](count); 
        for (uint i = 0; i < count; i++) {
            // MINT NFT's
            tokenIds[i] = freeMintNFTContract.mintNFT(msg.sender, baseURI , postFixURI); 
        }
        return tokenIds;
    }

    // Generates arbitrarily large random number
    function generateRandom(uint ind) private view returns (uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, ind)));
    }

    /**
     * Gets end state
     * @return The close time period for deposits
     */
    function getState() public view returns(uint) {
        uint256 timestamp = block.timestamp;
        if (timestamp < closeTime) {
            return 0;
        } else if (timestamp < bondTime || finalized == 0) {
            return 1;
        } else {
            return 2;
        }
    }

    /**
     * Gets close time
     * @return The close time period for deposits
     */
    function getCloseTime() public view returns(uint) {
        return closeTime;
    }

    /**
     * Gets end of bond time
     * @return The end of the bonding period
     */
    function getEndBondingPeriod() public view returns(uint) {
        return bondTime;
    }

    /**
     * Gets the total amount of tokens owned by the user
     * @param asset the ATOKEN contract address for the underlying token
     * @param user the address of the user
     * @return the number of TOKENS the user has in the protocol, multipled by 10^18
     */
    function getBalance(address asset, address user) public view returns(uint) {
        return getTotalBalance(asset) * userData[user][asset].shares / totalShares[asset];
    }

    /**
     * Gets the total amount of atokens owned
     * @param asset the ATOKEN contract address for the underlying token
     * @return the number of ATOKENS the pool has, multipled by 10^18
     */
    function getTotalBalance(address asset) public view returns(uint) {
        IERC20 aTokenContract = IERC20(asset);
        return aTokenContract.balanceOf(address(this));
    }

    /**
     * Converts some amount of atokens to shares
     * @param lpAsset the ATOKEN contract address for the underlying token
     * @param amount the number of ATOKENS the pool has, multipled by 10^18 
     * @return the number of shares that amount of ATOKENS is equivalent to
     */
    function convertToShares(address lpAsset, uint amount) internal view returns(uint) {
        return amount * totalShares[lpAsset] / getTotalBalance(lpAsset);
    }
    
    /**
     * Converts some amount of atokens to shares
     * @param lpAsset the ATOKEN contract address for the underlying token
     * @param shares the number of ATOKENS the pool has, multipled by 10^18 
     * @return the number of shares that amount of ATOKENS is equivalent to
     */
    function convertToAsset(address lpAsset, uint shares) internal view returns(uint) {
        return shares * getTotalBalance(lpAsset) / totalShares[lpAsset];
    }

    /**
     * Calculates the interest earned so far.
     * NOTE should prob be access controlled, only organization contract
     * @param lpAsset the ATOKEN contract address for the underlying token
     * @param neib non interest bearing part of the asset
     * @param shares number of shares that the interest is being calculated for
     */
    function calculateInterest(address lpAsset, uint neib, uint shares) public view returns(uint) {
        if (userData[msg.sender][lpAsset].shares == 0) {
            return 0;
        }

        uint assetEquivalent = convertToAsset(lpAsset, shares);
        uint neibEquivalent = neib * shares / userData[msg.sender][lpAsset].shares;
        if (assetEquivalent < neibEquivalent){
            return 0;
        }
        return assetEquivalent - neibEquivalent;
    }

    /**
     * Approves tokens for withdraw by the overarching organization
     * NOTE should prob be access controlled, only organization contract
     * @param asset the token contract address for the underlying token
     * @param amount the amount of assets to approve in the asset's native decimal amount
     */
    function approve(address asset, uint amount) public {
        assert(msg.sender == organization);
        IERC20 aTokenContract = IERC20(asset);
        aTokenContract.approve(organization, amount);
    }

    /**
     * Moves tokens to the overaching organization
     * NOTE should prob be access controlled, only organization contract
     * @param asset the token contract address for the underlying token
     * @param amount the amount of assets to transfer to the organization, in the asset's native decimal amount
     */
    function transfer(address asset, uint amount) public {
        assert(msg.sender == organization);
        IERC20 aTokenContract = IERC20(asset);
        aTokenContract.transfer(organization, amount);
    }

    /**
    * Generates a mapping of users to assets for shares
    * @param assetAddress the token contract address for the underlying token
    */
    function finalize(address assetAddress) internal {
        // In future, need to finalizeAll for multiple assets

        // User shares
        // uint[] memory userShares;
        // for (uint i = 0; i < users.length; i += 1) {
        //     address userAddress = users[i];
        //     userShares[i] = (userData[userAddress][assetAddress].shares);
        // }
        // uint totalSharesAsset = totalShares[assetAddress];
        finalized = 1;
        totalSharesFinalized[assetAddress] = totalShares[assetAddress]; 
        

        // // Generate and create the raffle contract
        // Raffle raffle = Raffle(address(this), nftContract); 
        // raffle.userRaffle(numNFTs, totalSharesAsset, users, usersToShares()); 
        // return (users, userShares, totalSharesAsset);
    }
     
}

