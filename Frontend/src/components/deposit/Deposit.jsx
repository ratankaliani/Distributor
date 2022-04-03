import React from 'react'
import './deposit.css'
import nftlogo from '../../assets/logo.png'
import { AiOutlineInstagram,AiOutlineTwitter, } from "react-icons/ai";
import { RiDiscordFill } from "react-icons/ri";
import { FaTelegramPlane } from "react-icons/fa";
const Deposit = () => {
  return (
    <>
    <div className="deposit-content">
        <div>
          <h1 className="counter">02:59:22</h1>
          <h2>Time Left to Stake</h2>
        </div>
      </div>

      
      <div className='footer section__padding'>
      <div className="footer-links">
        <div className="footer-links_logo">
        <div className='stake'>
          <div className="header-slider">
          <div>
            <h1>Stake Now!</h1>
          </div>
            </div>
            <input type="text" placeholder='ETH' />
            <button>Deposit</button>
          </div>
        </div>
      </div>
      
    </div>
    <div className="TVL-padding">
    <div className="TVL-content">
    <div>
          <h1 className='shake-vertical'>320 ETH</h1>
          <h2>TVL</h2>
        </div>
      </div>
      </div>
      </>
  )
}

export default Deposit;
