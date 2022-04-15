//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    uint256 private constant _tokenId = 1;

    constructor(
        string memory name,
        string memory symbol,
        address _auctionAddress,
        string memory _tokenURI
    ) ERC721(name, symbol) {
        _safeMint(_auctionAddress, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
    }
}
