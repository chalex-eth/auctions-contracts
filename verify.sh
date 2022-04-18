#!/bin/bash

. ./config.sh
. ./.env

contract=0x8a3cc1be5d9e3e43c0389bae61cc96c30f64c97c

forge verify-contract --compiler-version $compilerVersion --chain-id $chainid --num-of-optimizations 200 --constructor-args $(cast abi-encode "constructor(uint256,uint256,uint256,string,string,string)" ${arguments} ) $contract ./src/NFT_Auction.sol:NFT_Auction $etherscan
