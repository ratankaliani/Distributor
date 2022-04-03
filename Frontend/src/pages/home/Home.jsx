import React, { useState, useEffect, useCallback } from 'react';
import { Bids, Header, Deposit, Withdraw, Bonding } from '../../components'
import { ethers } from "ethers";
import { useAtom } from "jotai";
import { addrAtom } from "../../utils/atoms.js";
import tokensTestnet from "../../utils/tokens.js";
import Countdown from "react-countdown";

const Home = () => {
  const [state, setState] = useState({ page: 0, depositEndTime: Date.now() + 40000, bondingEndTime: Date.now() + 10000, wonNFTs: [0, 2, 5], time: Date.now()});

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
    state.page = 3; 
    state.wonNFTs = NFTs;
  }

  function handleAmountChange(e) {
    setState({...state, depositAmount: e.target.value}); 
  }

  useEffect(() => {
    // POTENTIAL ERROR: changing get state to function breaks the function 
    let isSubscribed = true; 
    const getState = async () => {
      const bEndTime = await contract.bondingEndTime;
      const dEndTime = await contract.depositEndTime;
      const time = Date.now(); 
      // TODO: uncomment below code once contract deployed
      // const page = state.page == 3 ? 3 : await contract.getState;  
      const page = 0; 
      if (isSubscribed) {
        setState({...state, bondingEndTime: Date.now() + 400000, depositEndTime: Date.now() + 400000, page: page})
      }
    }

    getState().catch(error => console.log(error)); 
    return () => isSubscribed = false
    
  }, []);

  // Options are deposit, bond, withdraw, claim

  return <div>
    <Header />
    {state.page == 0 ? (<Deposit endTime={state.depositEndTime}/>) :
      state.page == 1 ? (<Bonding endTime={state.bondingEndTime} />) :
        state.page == 2 ? (< Withdraw value="dummy" onChange={handleChange} depositAmount={state.depositAmount} />) :
          (< Bids NFTs={state.wonNFTs} />)}
    <></>

  </div>;
};

export default Home;