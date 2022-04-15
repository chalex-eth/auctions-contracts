//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Auction is ERC721Holder, ReentrancyGuard {
    enum AUCTION_STATE {
        OPEN,
        CLOSED
    }

    /// ------------------------------------------------------
    /// Storage var
    /// ------------------------------------------------------

    address public owner;

    ///@notice Timestamp when auction was started
    uint256 public startAuction;

    ///@notice Timestamp when auction was finished (24h after starting)
    uint256 public endAuction;

    ///@notice Price in ether of the current winning bid
    uint256 public bidPrice;

    ///@notice Address of the current winner bidder
    address public bidder;

    ///@notice Track when someone made a bid
    bool private isBidded = false;

    ///@notice NFT address
    address public NFTaddress;

    ///@notice State of the auction
    AUCTION_STATE private auctionState = AUCTION_STATE.CLOSED;

    /// ------------------------------------------------------
    /// Constants
    /// ------------------------------------------------------

    ///@notice Time Auction will last
    uint256 public immutable AUCTION_DURATION;

    ///@notice Min price for NFT
    uint256 public immutable MIN_PRICE;

    ///@notice Min delta between 2 bids
    uint256 public immutable MIN_BID;

    /// ------------------------------------------------------
    /// Events
    /// ------------------------------------------------------

    event LaunchAuction(uint256 StartTimestamp, uint256 EndTimestamp);
    event Bid(address indexed BidderAddress, uint256 BidPrice);

    /// ------------------------------------------------------
    /// Errors
    /// ------------------------------------------------------

    error Error_AuctionNotClosed();
    error Error_AuctionNotOpen();
    error Error_AuctionDeadlineEnded();
    error Error_BidTooLow();
    error Error_AuctionNotEnded();
    error Error_CallerNotOwner();

    /// ------------------------------------------------------
    /// Init
    /// ------------------------------------------------------
    constructor(
        uint256 AUCTION_DURATION_,
        uint256 MIN_PRICE_,
        uint256 MIN_BID_
    ) {
        AUCTION_DURATION = AUCTION_DURATION_;
        MIN_PRICE = MIN_PRICE_;
        MIN_BID = MIN_BID_;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Error_CallerNotOwner();
        }
        _;
    }

    /// ------------------------------------------------------
    /// Admin action
    /// ------------------------------------------------------

    function startingAuction(address _NFTaddress) external onlyOwner {
        if (auctionState != AUCTION_STATE.CLOSED) {
            revert Error_AuctionNotClosed();
        }
        auctionState = AUCTION_STATE.OPEN;
        startAuction = block.timestamp;
        endAuction = startAuction + AUCTION_DURATION;
        NFTaddress = _NFTaddress;
        emit LaunchAuction(startAuction, endAuction);
    }

    function endingAuction() external onlyOwner {
        if (block.timestamp < endAuction) {
            revert Error_AuctionNotEnded();
        }
        IERC721(NFTaddress).approve(bidder, 1);
        IERC721(NFTaddress).safeTransferFrom(address(this), bidder, 1);
    }

    function withdrawFund() external onlyOwner {
        if (block.timestamp < endAuction) {
            revert Error_AuctionNotEnded();
        }

        Address.sendValue(payable(owner), address(this).balance);
    }

    /// ------------------------------------------------------
    /// Users actions
    /// ------------------------------------------------------

    function setBid() external payable nonReentrant {
        if (auctionState == AUCTION_STATE.CLOSED) {
            revert Error_AuctionNotOpen();
        }
        if (block.timestamp > endAuction) {
            revert Error_AuctionDeadlineEnded();
        }
        if (msg.value < MIN_PRICE) {
            revert Error_BidTooLow();
        }
        if (msg.value < (bidPrice + MIN_BID)) {
            revert Error_BidTooLow();
        }
        if (isBidded == false) {
            // Handle first bid
            _setBidder(msg.sender, msg.value);
            isBidded = true;
        } else {
            // Handle other bids
            uint256 _valueToSend = bidPrice;
            address _recipient = bidder;
            bidPrice = 0;
            Address.sendValue(payable(_recipient), _valueToSend);
            _setBidder(msg.sender, msg.value);
        }
    }

    /// ------------------------------------------------------
    /// Internal functions
    /// ------------------------------------------------------

    function _setBidder(address _bidder, uint256 _bidPrice) private {
        bidder = _bidder;
        bidPrice = _bidPrice;
        emit Bid(_bidder, _bidPrice);
    }
}
