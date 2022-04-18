#!/bin/sh

auctionDuration=86400 # 1 day in second
minPrice=1000000000000000000 # 1 ether
minBid=100000000000000000 # 0.1 ether
name="My NFT"
symbol="NFT"
tokenURI=""

export arguments="$auctionDuration $minPrice $minBid $name $symbol $tokenURI"
export chainid=42
export compilerVersion="v0.8.12+commit.f00d7308"