import React from "react";
import {useState, useEffect} from "react"
import "./deposit.css";
import { ethers } from "ethers";
import { useAtom } from "jotai";
import { addrAtom } from "../../utils/atoms.js";
import tokensTestnet from "../../utils/tokens.js"
import Countdown from "react-countdown";

const Deposit = (props) => {
  const [address, setAddress] = useAtom(addrAtom);
  const [amount, setAmount] = useState(0);
  const [token, setToken] = useState('');
  const [lp, setLp] = useState('');
  const [totalBal, setTotalBal] = useState(0);

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
    const getBalance = async () => {
        try {
          const contBal = await contract.getBalance(contract);
          setTotalBal(contBal);
        } catch(error) {
          console.log(error);
        }
    };
    getBalance();
}, []);

  async function handleDeposit() {
    const tokenAddr = tokensTestnet[token].address;
    const lpAssetAddr = tokensTestnet[lp].address;
    await contract.deposit(tokenAddr, lpAssetAddr, amount);
  }

  function handleTokenChange(e) {
    setToken(e.target.value)
  }

  function handleAmountChange(e) {
    setAmount(e.target.value)
  }

  function handleLpChange(e) {
    setLp(e.target.value)
  }

  return (
    <>
      <div className="deposit-content">
        <div>
          <span className="counter">
              <Countdown date={props.endTime}/>
          </span>
          <h2>Time Left to Stake</h2>
        </div>
      </div>

      <div className="footer section__padding">
        <div className="footer-links">
          <div className="footer-links_logo">
            <div className="stake">
              <div className="header-slider">
                <div>
                  <h1>Stake Now!</h1>
                </div>
              </div>
              <input type="text" placeholder="Underlying Asset" value ={token} onChange = {handleTokenChange}/>
              <input type="text" placeholder="LP Asset" value ={lp} onChange = {handleLpChange}/>
              <input type="text" placeholder="Amount" value ={amount} onChange = {handleAmountChange}/>
              <button onClick={handleDeposit}>Deposit</button>
            </div>
          </div>
        </div>
      </div>
      <div className="TVL-padding">
        <div className="TVL-content">
          <div>
            <h1 className="shake-vertical">{totalBal} {token}</h1>
            <h2>TVL</h2>
          </div>
        </div>
      </div>
    </>
  );
};

export default Deposit;
