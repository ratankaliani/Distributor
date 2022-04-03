import React from 'react'
import './bids.css'
import { AiFillHeart,AiOutlineHeart } from "react-icons/ai";
import { Link } from 'react-router-dom';


const images = ["https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-1.jpeg",
                "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/bird-2.png",
              "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-3.jpeg",
            "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-4.jpeg",
          "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-5.jpeg",
        "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-6.jpeg",
      "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-7.jpeg",
    "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-8.jpeg",
  "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-9.jpeg",
  "https://gateway.pinata.cloud/ipfs/QmQPznjQJcRFeF3pUPq1vPu1Fy9bohrpismWUvhxpndECn/birds-10.jpeg"
];

const Bids = ({title, showAll}) => {

  // NOTE: replace [0, 2, 5] with contract result
  const transferred = showAll ? [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] : [0, 2, 5];

  return (
      <div className="bids-container">
        <div className="bids-container-text">
          <h1>{title}</h1>
        </div>
        <div className="bids-container-card">
          {transferred.map(transferredIndex => (
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
