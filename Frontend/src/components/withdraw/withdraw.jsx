import React from 'react'
import './withdraw.css'
import nftlogo from '../../assets/logo.png'
import { AiOutlineInstagram,AiOutlineTwitter, } from "react-icons/ai";
import { RiDiscordFill } from "react-icons/ri";
import { FaTelegramPlane } from "react-icons/fa";

const Withdraw = (props) => {

  function handleClick(event) {
    props.onChange("claim"); 
  }

  return (
    <>
    <div className='withdraw-content'>
        <div className='stake'>
            <h1> Bonding Period Has Completed! </h1>
            <h2> Withdraw to see if you won an NFT </h2>
            <button onClick={handleClick} className='gradient-button'>Withdraw</button>
        </div>
        <h3> 30% Accrued In Vault </h3>
    </div>
      </>
  )
}

export default Withdraw;
