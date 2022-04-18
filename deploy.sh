#!/bin/sh

. ./config.sh
. ./.env

forge create ./src/NFT_Auction.sol:NFT_Auction --rpc-url $rpc_url --private-key $private_key --constructor-args ${arguments}