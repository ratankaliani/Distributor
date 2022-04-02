import React, { useState } from 'react';
import {Bids, Header, Deposit} from '../../components'



const Home = () => {
  // Options are deposit, bond, withdraw, claim

  const [page, setPage] = useState("deposit");

  return <div>
   <Header />
    {page == "deposit" ? (<Deposit/>) : 
    page == "claim" ? (<Bids title="Collection"  />) :
    <></>
}

   
  </div>;
};

export default Home;
