import React, { useState } from "react";
import "./navbar.css";
import { RiMenu3Line, RiCloseLine } from "react-icons/ri";
import logo from "../../assets/logo.png";
import { Link } from "react-router-dom";
import { ethers } from "ethers";
import { useAtom } from "jotai"
import { addrAtom } from "../../utils/atoms.js"

const Navbar = () => {
  const [toggleMenu, setToggleMenu] = useState(false);
  const [user, setUser] = useState(false);
  const [address, setAddress] = useAtom(addrAtom);

  // Metamask connect
  const provider = new ethers.providers.Web3Provider(window.ethereum);

  const handleLogout = () => {
    setUser(false);
  };
  async function handleLogin () {
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    let userAddress = await signer.getAddress();
    setAddress(userAddress);
    setUser(true);
  };

  return (
    <div className="navbar">
      <div className="navbar-links">
        <div className="navbar-links_logo">
          <img src={logo} alt="logo" />
          <Link to="/">
            <h1>FreeMint</h1>
          </Link>
        </div>
        <div className="navbar-links_container">
          <input type="text" placeholder='Search Item Here' autoFocus={true} />
         {/* <Menu /> */}
         {user && <Link to="/"><p onClick={handleLogout}>Logout</p></Link> }
        
        </div>
      </div>
      <div className="navbar-sign">
      {user ? (
              <>
              <Link to="/"> 
                <button type='button' className='secondary-btn' >Connected</button>
              </Link>
              </>
            ): (
              <>
              <Link to="/"> 
              <button type='button' className='primary-btn' onClick={handleLogin} >Connect</button>
              </Link>
              </>
            )}
       

       
      </div>
      <div className="navbar-menu">
        {toggleMenu ? (
          <RiCloseLine
            color="#fff"
            size={27}
            onClick={() => setToggleMenu(false)}
          />
        ) : (
          <RiMenu3Line
            color="#fff"
            size={27}
            onClick={() => setToggleMenu(true)}
          />
        )}
        {toggleMenu && (
          <div className="navbar-menu_container scale-up-center">
            <div className="navbar-menu_container-links">
            </div>
            <div className="navbar-menu_container-links-sign">
            {user ? (
              <>
              <Link to="/"> 
                <button type='button' className='secondary-btn' >Connected</button>
              </Link>
              </>
            ): (
              <>
              <Link to="/"> 
              <button type='button' className='primary-btn' onClick={handleLogin} >Connect</button>
              </Link>
              </>
            )}
           
            </div>
            </div>
        )}
      </div>
    </div>
  );
};

export default Navbar;
