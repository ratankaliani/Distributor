import React, { useState, useEffect } from 'react';
import {Bids, Header, Deposit, Bonding, Withdraw} from '../../components'
import Countdown from "react-countdown"; 

const Home = () => {
  // Options are deposit, bond, withdraw, claim

  const [state, setState] = useState({page: "deposit", endDate: 1648976520480, seconds: 0}); 

  useEffect(() => {
    console.log(state.endDate); 
    const interval = setInterval(() => {
      setState({...state, seconds: state.seconds + 1});
    }, 1000);
    
    if (Date.now() >= state.endDate) {
      // TO DO: CONTRACT CALL
      if (state.page == "deposit") {
        // SWITCH TO BONDING 
        var bondEndDate = Date.now() + 10000; // contractQuery.getBondingEndDate(); 
        setState({endDate: bondEndDate, page: "bonding"}); 
      } else if (state.page == "bonding") {
        // SWITCH BACK TO DEPOSIT 
        var depositEndDate = Date.now() + 10000; // contractQuery.getDepositEndDate(); 
        setState({endDate: depositEndDate, page: "withdraw"}); 
      }
    } 
    return () => clearInterval(interval);
    
  })
  
 function handleChange(newState) {
    setState({...state, pagep: newState}); 
  }

  return <div>
   <Header />
    {state.page == "deposit" ? (<Deposit/>) : 
    state.page == "withdraw" ? (<Withdraw onChange={handleChange}/>):
    state.page == "bonding" ? (<Bonding/>) :
    state.page == "claim" ? (<Bids title="Collection"/>) :
    <></>
}

   
  </div>;
};

export default Home;

/*
1. Bond time clock + close deposit clock (logic for clock)
2. When clock hits zero, switch pages 
*/