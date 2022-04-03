import React from "react";
import { useState, useEffect } from "react"
import "./deposit.css";
import { ethers } from "ethers";
import { useAtom } from "jotai";
import { addrAtom } from "../../utils/atoms.js";
import tokensTestnet from "../../utils/tokens.js"
import Countdown from "react-countdown";

const Deposit = (props) => {
  const [address, setAddress] = useAtom(addrAtom);
  const [amount, setAmount] = useState(''); // num of funds
  const [token, setToken] = useState('ETH');
  const [lp, setLp] = useState('aToken'); // address of A Token
  const [totalBal, setTotalBal] = useState(0);

  // MINT POOL ABI
  let abi = require("../../utils/FreeMintPool.json")["abi"]

  let provider = ethers.getDefaultProvider();

  // MINT POOL CONTRACT
  let contractAddress = "0x85ae1b49c9e51a3a8d4a81b94ce9f34e45246dec";

  // We connect to the Contract using a Provider, so we will only
  // have read-only access to the Contract
  let contract = new ethers.Contract(contractAddress, abi, provider);

  useEffect(() => {
    const getBalance = async () => {
      try {
        const contBal = await contract.getBalance(contract);
        setTotalBal(contBal);
        console.log(totalBal)
      } catch (error) {
        console.log(error);
      }
    };
    getBalance();
  }, [amount, token, lp, totalBal]);

  async function handleDeposit() {
    //const tokenAddr = tokensTestnet[token].address;
    //const lpAssetAddr = tokensTestnet[lp].address;
    await contract.deposit("0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", amount);
  }

  function handleAmountChange(e) {
    setAmount(e.target.value)
  }

  return (
    <>
      <div className="deposit-content">
        <div>
          <h1 className="counter">
            <Countdown date={props.endTime} />
          </h1>

          <h2>Time Left to Stake</h2>
        </div>
      </div>

      <div className="footer section__padding">
        <div className="footer-links">
          <div className="footer-links_logo">
            <div>
              <div className="header-slider">
                <div>
                  <h1>Stake Now!</h1>
                </div>
              </div>
              {/* <input type="text" placeholder="Underlying Asset" value={token} />  */}
              {/* <input type="text" placeholder="LP Asset" value={lp} onChange={handleLpChange} />  */}
              <input type="text" placeholder="Amount" value={amount} onChange={handleAmountChange} />
              <button onClick={handleDeposit}>Deposit</button>

            </div>
          </div>
        </div>
      </div>
      <div className="TVL-padding">
        <div className="TVL-content">
          <div>
            <h1 className="shake-vertical">{totalBal}</h1>
            <h2>TVL</h2>
          </div>
        </div>
      </div>
    </>
  );
};

export default Deposit;
