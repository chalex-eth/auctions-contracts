// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "forge-std/Test.sol";
import "../NFT.sol";

contract NFT_Test is Test {
    address auction = address(0x1337);
    NFT nft;

    function setUp() public {
        vm.label(auction, "Auction");
        string memory tokenURI = " ";
        nft = new NFT("My NFT", "NFT", auction, tokenURI);
    }

    function test_InitParameter() public {
        assertEq(nft.ownerOf(1), auction);
        assertEq(nft.tokenURI(1), " ");
        assertEq(nft.name(), "My NFT");
        assertEq(nft.symbol(), "NFT");
    }
}
