# NFT auction for unique NFT

This repo is a template that allow to mint a unique NFT and sell it through an auction. 

Constructor take several inputs to parametrize the contracts.
```AUCTION_DURATION``` in second (86400 for 1 day)
```MIN_PRICE``` price in Gwei for the starting price of the NFT 
```MIN_BID``` minimal delta between 2 bid
```name``` name of the NFT
```symbol``` symbol of the NFT

Once the contract is deployed:  
- owner of the contract can call ```startingAuction()``` to start the auction and allow bid
- once auction is ended owner can call ```endingAuction()``` to end the auction and transfer the NFT to the winning bidder
- owner can call ```withdrawFund()``` once auction is ended

# Installation

## Requirements

- [Foundry](https://github.com/foundry-rs/foundry) installed 
- Clone the repo
- Create a .env file containing the following 

```
export private_key=
export rpc_url=
export etherscan=
```

## Set up

Edit the config.sh with the desired inputs

You can run ```forge test```

To deploy and verify the contract run ```make all```


# Disclaimer

Do not use this contract in production mode, when an user call the setBid() function, there is a refund process for the previous bidder. 
This method is subject to DoS attack, you need to implement a pull over refund instead of push refund.
[Consensys best practice](https://consensys.github.io/smart-contract-best-practices/development-recommendations/general/external-calls/)
