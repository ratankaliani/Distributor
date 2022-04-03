import React from 'react';
import { RiDiscordFill } from "react-icons/ri";
import "./bonding.css"
import Countdown from "react-countdown"; 

const Bonding = (props) => {
    return (
        <>
        <h1 className="bondingtitle">Bonding Time</h1>
        <div className="bonding-content">
            <div>
                <h1 className="counter">
                    <Countdown date={props.endTime}/>
                </h1>
                <div className='yieldContainer'>
                    <h2>+yield%</h2>
                </div>
            </div>
        </div>
        </>
    )
} 
export default Bonding;