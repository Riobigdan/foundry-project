// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// https://eips.ethereum.org/EIPS/eip-721
contract BasicNft is ERC721 {
    // token Counter
    uint256 private s_tokenCounter;

    // Mapping from token ID to the owner address
    mapping(uint256 => address) private s_tokenIdToOwner;
    mapping(uint256 => string) private s_tokenIdToUri;

    constructor() ERC721("Dadan", "DADAN") {
        s_tokenCounter = 0;
    }
    /**
     * @dev 铸造NFT
     * @param tokenUri NFT的URI
     */

    function mintNft(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    /**
     * @dev 返回NFT的URI
     * @param tokenId NFT的ID
     * @return NFT的URI
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }
}
