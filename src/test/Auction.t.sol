// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "forge-std/Test.sol";
import "../NFT_Auction.sol";

contract Auction_Test is Test {
    NFT_Auction auction;

    address alice = address(0x1337);
    address bob = address(0x133702);

    function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        vm.startPrank(alice);
        string memory tokenURI = " ";
        auction = new NFT_Auction(
            86400,
            1 ether,
            1 ether / 10,
            "My NFT",
            "NFT",
            tokenURI
        ); // Create an auction for 24h with a 1 ether starting bid price and 0.1 bid increment
        vm.stopPrank();
    }

    function testSetUp() public {
        assertEq(auction.AUCTION_DURATION(), 86400);
        assertEq(auction.MIN_PRICE(), 1 ether);
        assertEq(auction.MIN_BID(), 1 ether / 10);
        assertEq(auction.ownerOf(1), address(auction));
        assertEq(auction.tokenURI(1), " ");
        assertEq(auction.name(), "My NFT");
        assertEq(auction.symbol(), "NFT");
    }

    ///-------------------------
    /// Test startingAuction
    ///-------------------------

    ///@notice Test onlyOwner can start
    function testFuzz_OwnerStartingAuction(address randomSender) public {
        vm.expectRevert(NFT_Auction.Error_CallerNotOwner.selector);
        vm.prank(randomSender);
        auction.startingAuction();
    }

    ///@notice Check if init parameter are ok
    function test_ParamsStartingAuction(uint256 timestamp) public {
        vm.assume(timestamp < 1679899651); // Assume a timestamp prior to 2023
        vm.prank(alice);
        vm.warp(timestamp);
        auction.startingAuction();
        assertEq(auction.startAuction(), timestamp);
        assertEq(auction.endAuction(), timestamp + 86400);
    }

    ///-------------------------
    /// Test endingAuction
    ///-------------------------

    ////@notice Test onlyOwner can end auction
    function testFuzz_OwnerEndingAuction(address randomSender) public {
        vm.expectRevert(NFT_Auction.Error_CallerNotOwner.selector);
        vm.prank(randomSender);
        auction.endingAuction();
    }

    ///@notice Revert tx if try to end auction too soon
    function testFuzz_revertAuctionNotEnded(
        uint256 timestamp,
        uint256 timetravel
    ) public {
        vm.assume(timestamp < 1679899651); // Assume a timestamp prior to 2023
        vm.assume(timetravel < 86400);
        vm.startPrank(alice);
        vm.warp(timestamp);
        auction.startingAuction();
        vm.warp(timestamp + timetravel);
        vm.expectRevert(NFT_Auction.Error_AuctionNotEnded.selector);
        auction.endingAuction();
        vm.stopPrank();
    }

    ///@notice Test if bidder get the NFT
    function test_transferNFT() public {
        vm.deal(bob, 10 ether);
        vm.prank(alice);
        auction.startingAuction();
        vm.prank(bob);
        auction.setBid{value: 1 ether}();
        vm.warp(86401);
        vm.prank(alice);
        auction.endingAuction();
        console.log(auction.bidder());
        assertEq(auction.ownerOf(1), bob);
        assertEq(auction.bidder(), bob);
        assertEq(auction.bidPrice(), 1 ether);
    }

    ///-------------------------
    /// Test setBid
    ///-------------------------

    function test_RevertAuctionNotOpen() public {
        vm.deal(bob, 10 ether);
        vm.expectRevert(NFT_Auction.Error_AuctionNotOpen.selector);
        auction.setBid{value: 5 ether}();
    }

    function test_RevertAuctionClosed() public {
        vm.deal(bob, 10 ether);
        vm.prank(alice);
        auction.startingAuction();
        vm.warp(86401);
        vm.expectRevert(NFT_Auction.Error_AuctionDeadlineEnded.selector);
        auction.setBid{value: 5 ether}();
    }

    function testFuzz_RevertFirstAuctionTooLow(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < 1 * (10**18));
        vm.deal(bob, amount);
        vm.prank(alice);
        auction.startingAuction();
        vm.startPrank(bob);
        vm.expectRevert(NFT_Auction.Error_BidTooLow.selector);
        auction.setBid{value: amount}();
    }

    function testFuzz_FirstAuction(uint256 amount, address bidder) public {
        vm.assume(amount >= 1 * (10**18));
        vm.deal(bidder, amount);
        vm.prank(alice);
        auction.startingAuction();
        vm.startPrank(bidder);
        auction.setBid{value: amount}();
        assertEq(amount, auction.bidPrice());
        assertEq(bidder, auction.bidder());
    }

    function test_FirstAuction() public {
        vm.deal(bob, 6 ether);
        vm.prank(alice);
        auction.startingAuction();
        vm.startPrank(bob);
        auction.setBid{value: 1 ether}();
        assertEq(1 ether, auction.bidPrice());
        assertEq(bob, auction.bidder());
    }

    function test_Bid() public {
        uint256 bid1 = 1 ether;
        uint256 bid2 = 1.2 ether;
        vm.deal(bob, bid1);
        vm.deal(alice, bid2);
        vm.prank(alice);
        auction.startingAuction();
        vm.prank(bob);
        auction.setBid{value: bid1}();
        assertEq(bid1, auction.bidPrice());
        assertEq(bob, auction.bidder());

        vm.prank(alice);
        auction.setBid{value: bid2}();
        assertEq(bid2, auction.bidPrice());
        assertEq(alice, auction.bidder());
    }
}
