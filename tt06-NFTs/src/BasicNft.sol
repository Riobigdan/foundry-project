// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// https://eips.ethereum.org/EIPS/eip-721
contract BsicNFft is ERC721 {
    // token Counter
    uint256 private s_tokenCounter;

    // Mapping from token ID to the owner address
    mapping(uint256 => address) private s_tokenIdToOwner;

    constructor() ERC721("Dadan", "DADAN") {
        s_tokenCounter = 0;
    }

    function mintNft() public {
        _mint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return "";
    }
}
