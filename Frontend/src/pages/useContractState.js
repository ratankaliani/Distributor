import { useState, useEffect } from 'react';
import { ethers } from "ethers";
import { useAtom } from "jotai";
import { addrAtom } from "../utils/atoms.js";
import tokensTestnet from "../utils/tokens.js";

export default function useContractState() {
    const [state, setState] = useState({ page: 0, depositEndTime: Date.now() + 40000, bondingEndTime: Date.now() + 10000, wonNFTs: [0, 2, 5], time: Date.now() });

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
        // POTENTIAL ERROR: changing get state to function breaks the function 
        let isSubscribed = true;
        const getState = async () => {
            // const bEndTime = await contract.bondingEndTime;
            // const dEndTime = await contract.depositEndTime;
            const time = Date.now();
            // TODO: uncomment below code once contract deployed
            // const page = state.page == 3 ? 3 : await contract.getState;  
            const page = 0; 
            if (isSubscribed) {
                setState({ ...state, page: page })
            }
        }

        getState().catch(error => console.log(error));
        return () => isSubscribed = false; 

    }, [state]);

    return state; 
}