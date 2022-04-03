import React, { useState } from 'react';
import {Bids, Header, Deposit} from '../../components'
import { ethers } from "ethers";
import { useAtom } from "jotai";
import { addrAtom } from "../../utils/atoms.js";
import tokensTestnet from "../../utils/tokens.js"

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

  useEffect(() => {
    const getState = async () => {
        try {
          const contState = await contract.getState();
          setPage(contState);
        } catch(error) {
          console.log(error);
        }
    };
    getState();
}, []);

  // Options are deposit, bond, withdraw, claim

  const [page, setPage] = useSta;

  return <div>
   <Header />
    {page == 0 ? (<Deposit/>) : 
    page == 1 ? (<></>) :
    page == 2 ? (< Withdraw  />) :
    <></>
}

   
  </div>;
};

export default Home;
