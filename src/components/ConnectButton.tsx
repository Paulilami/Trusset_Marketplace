"use client"
import { Button } from '@mui/material'
import { ethers } from 'ethers';
import React, { useEffect, useState } from 'react'
import detectEthereumProvider from '@metamask/detect-provider'


const ConnectButton:React.FC = () => {
    const [hasProvider, setHasProvider] = useState<any>(null)
  const initialState = { accounts: [] }
  const [wallet, setWallet] = useState(initialState)
//   const dispatch = useDispatch();

  useEffect(() => {
    const refreshAccounts = (accounts:any) => {                
      if (accounts.length > 0) {                                
        updateWallet(accounts)                                  
      } else {                                                  
        setWallet(initialState)  
        // dispatch(setAccountsRed(initialState))                               
      }                                                         
    }                                                           

    const getProvider = async () => {
      const provider = await detectEthereumProvider({ silent: true })
      setHasProvider(provider)

      if (provider) {                                           
        const accounts = await window.ethereum.request(         
          { method: 'eth_accounts' }                            
        )                                                       
        refreshAccounts(accounts)                               
        window.ethereum.on('accountsChanged', refreshAccounts)  
      }                                                         
    }

    getProvider()
    return () => {                                              
      window.ethereum?.removeListener('accountsChanged', refreshAccounts)
    }                                                           
  }, [])

  const updateWallet = async (accounts:any) => {
    setWallet({ accounts });
    // dispatch(setAccountsRed( accounts[0]))                               
  }

  const handleConnect = async () => {
    let accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    })
    updateWallet(accounts)
  }

  return (
    <div className="App">

      { window.ethereum?.isMetaMask && wallet.accounts.length < 1 &&  
        <Button 
        color="primary"
        aria-label="menu"
        onClick={handleConnect}>Connect MetaMask</Button>
      }

      { wallet.accounts.length > 0 &&
        <div>Wallet Accounts: { wallet.accounts[0] }</div>
      }
    </div>
  )
}

export default ConnectButton