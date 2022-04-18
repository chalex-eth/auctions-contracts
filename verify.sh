#!/usr/bin/env bash

. ./config.sh
. ./.env

echo Enter the contract address to verifiy
read contract

forge verify-contract --compiler-version $compilerVersion --chain-id $chainid --num-of-optimizations 200 --constructor-args $(cast abi-encode "constructor(uint256,uint256,uint256,string,string,string)" ${arguments} ) $contract ./src/NFT_Auction.sol:NFT_Auction $etherscan
