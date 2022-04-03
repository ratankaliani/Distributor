import React, {useState} from 'react'
import './withdraw.css'
import nftlogo from '../../assets/logo.png'
import { AiOutlineInstagram,AiOutlineTwitter, } from "react-icons/ai";
import { RiDiscordFill } from "react-icons/ri";
import { FaTelegramPlane } from "react-icons/fa";
import { ethers } from "ethers";
import { useAtom } from "jotai";
import { addrAtom } from "../../utils/atoms.js";
import tokensTestnet from "../../utils/tokens.js"

const Withdraw = (props) => {

  const [token, setToken] = useState('ETH');
  const [lp, setLp] = useState('aToken');

  let abi = [
    "event ValueChanged(address indexed author, string oldValue, string newValue)",
    "constructor(string value)",
    "function getValue() view returns (string value)",
    "function setValue(string value)",
  ];

  let provider = ethers.getDefaultProvider();

  let contractAddress = "0x2bD9aAa2953F988153c8629926D22A6a5F69b14E";
  // We connect to the Contract using a Provider, so we will only
  // have read-only access to the Contract
  let contract = new ethers.Contract(contractAddress, abi, provider);

  async function handleWithdraw() {
    const tokenAddr = tokensTestnet[token].address;
    const lpAssetAddr = tokensTestnet[lp].address;
    await contract.withdraw(tokenAddr, lpAssetAddr);
  }

  // WONNFTS?? 
  function handleClick(event) {
    // await handleWithdraw(); 
    const wonNFTs = [0, 2, 5]; // handleWithdraw(); 
    props.onChange(wonNFTs);
  }

  return (
    <>
    <div className='withdraw-content'>
        <div className='stake'>
            <h1> Bonding Period Has Completed! </h1>
            <h2> Withdraw to see if you won an NFT </h2>
            <button onClick={handleClick} className='gradient-button'>Withdraw</button>
            {/* <input type="text" placeholder="Underlying Asset" value ={token} onChange = {handleTokenChange}/> */}
            {/* <input type="text" placeholder="LP Asset" value ={lp} onChange = {handleLpChange}/> */}
        </div>
        <h3> 30% Accrued In Vault </h3>
    </div>
      </>
  )
}

export default Withdraw;
