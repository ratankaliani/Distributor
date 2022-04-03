import React from 'react';
import { RiDiscordFill } from "react-icons/ri";
import "./bonding.css"


const Bonding = () => {
    return (
        <>
        <h1 className="bondingtitle">Bonding Time</h1>
        <div className="bonding-content">
            <div>
                <h1 className="counter">02:59:22</h1>
                <div className='yieldContainer'>
                    <h2>+yield%</h2>
                </div>
            </div>
        </div>
        </>
    )
} 
export default Bonding;