import React from 'react'
import './bids.css'
import { AiFillHeart,AiOutlineHeart } from "react-icons/ai";

const images = ["https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-1.jpeg",
                "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-2.jpeg",
              "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-3.jpeg",
            "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-4.jpeg",
          "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-5.jpeg",
        "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-6.jpeg",
      "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-7.jpeg",
    "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-8.jpeg",
  "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-9.jpeg",
  "https://gateway.pinata.cloud/ipfs/Qme3S2kFryHXZBcMF44jsJZd8BshskxrBbY773NcwY6MVE/birds-10.jpeg"
];

const Bids = ({title, wonNFTs}) => {

  // NOTE: replace [0, 2, 5] with contract result
  return (
      <div className="bids-container">
        <div className="bids-container-text">
          <h1>{title}</h1>
        </div>
        <div className="bids-container-card">
          {wonNFTs.map(transferredIndex => (
            <>
              <div className="card-column">
                <div className="bids-card">
                  <div className="bids-card-top">
                    <img src={images[transferredIndex]} alt="" />
                      <p className="bids-title">Bird</p>
                  </div>
                  <div className="bids-card-bottom">
                    <p>0.20 <span>ETH</span></p>
                    <p> <AiFillHeart /> 25</p>
                  </div>
                </div>
              </div>
            </>
          ))}
        </div>
      <div className="load-more">
        <button>Load More</button>
      </div>
    </div>
  )
}

export default Bids
