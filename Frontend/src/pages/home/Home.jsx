import React, { useState, useEffect } from 'react';
import {Bids, Header, Deposit, Withdraw, Bonding} from '../../components'
import { ethers } from "ethers";
import { useAtom } from "jotai";
import { addrAtom } from "../../utils/atoms.js";
import tokensTestnet from "../../utils/tokens.js"; 
import Countdown from "react-countdown"; 

const Home = () => {

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


  function handleChange(NFTs) {
    setState({...state, page: 3, wonNFTs: NFTs}); 

  }

  useEffect(() => {
    const getState = async () => {
        try {
          const contState = await contract.getState();
          setState({...state, page: contState});
        } catch(error) {
          console.log(error);
        }
    };
    getState();
}, []);

  // Options are deposit, bond, withdraw, claim

  const [state, setState] = useState({page: 0, depositEndTime: 0, bondingEndTime: 0, wonNFTs: []});
  return <div>
   <Header />
    {state.page == 0 ? (<Deposit endTime={state.depositEndTime}/>) : 
    state.page == 1 ? (<Bonding endTime={state.bondingEndTime}/>) :
    state.page == 2 ? (< Withdraw onChange={handleChange} />) :
    (< Bids NFTs={state.wonNFTs}/>) } 
    <></>
   
  </div>;
};

export default Home;

/*
1. Bond time clock + close deposit clock (logic for clock)
2. When clock hits zero, switch pages 
*/