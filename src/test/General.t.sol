// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "forge-std/Test.sol";
import "../NFT.sol";
import "../Auction.sol";

contract Auction_Test is Test {
    NFT nft;
    Auction auction;

    address admin = address(0x1337);
    address bidder1 = address(0x133702);
    address bidder2 = address(0x133703);
    address bidder3 = address(0x133704);
    address bidder4 = address(0x133705);

    function setUp() public {
        vm.label(admin, "admin");
        vm.label(bidder1, "Bidder1");
        vm.label(bidder2, "Bidder2");
        vm.label(bidder3, "Bidder3");
        vm.label(bidder4, "Bidder4");

        vm.startPrank(admin);
        auction = new Auction(86400, 1 ether, 1 ether / 10); // Create an auction for 24h with a 1 ether starting bid price and 0.1 bid increment
        string memory tokenURI = " ";
        nft = new NFT("My NFT", "NFT", address(auction), tokenURI);
        vm.stopPrank();
    }

    function test_FullAuction() public {
        vm.warp(100);
        vm.prank(admin);
        auction.startingAuction(address(nft));
        assertEq(auction.startAuction(), 100);
        assertEq(auction.endAuction(), 86500);

        vm.deal(bidder1, 1 ether);
        vm.deal(bidder2, 3 ether);
        vm.deal(bidder3, 4.2 ether);
        vm.deal(bidder4, 10 ether);

        vm.prank(bidder1);
        auction.setBid{value: 1 ether}();
        assertEq(auction.bidder(), bidder1);
        assertEq(auction.bidPrice(), 1 ether);

        vm.prank(bidder2);
        auction.setBid{value: 3 ether}();
        assertEq(auction.bidder(), bidder2);
        assertEq(auction.bidPrice(), 3 ether);
        assertEq(address(bidder1).balance, 1 ether);

        vm.prank(bidder3);
        auction.setBid{value: 4.2 ether}();
        assertEq(auction.bidder(), bidder3);
        assertEq(auction.bidPrice(), 4.2 ether);
        assertEq(address(bidder2).balance, 3 ether);

        vm.prank(bidder4);
        auction.setBid{value: 10 ether}();
        assertEq(auction.bidder(), bidder4);
        assertEq(auction.bidPrice(), 10 ether);
        assertEq(address(bidder3).balance, 4.2 ether);

        vm.warp(86501);
        vm.prank(admin);
        auction.endingAuction();
        assertEq(nft.ownerOf(1), bidder4);

        vm.prank(admin);
        auction.withdrawFund();
        assertEq(address(admin).balance, 10 ether);
    }
}
