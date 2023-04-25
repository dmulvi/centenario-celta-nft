// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CentenarioCelta is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter;
    using Strings for uint256;

    event InStoreMint(uint256 tokenId);
    event OnlineMint(uint256 tokenId);

    Counters.Counter private _tokenIdCounter;

    uint256 public constant MAX_SUPPLY = 500;
    uint256 public price = 0.01 ether; // 10 MATIC

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public crossmintAddress;

    constructor(address _crossmint) ERC721("Centenario Celta", "CLT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _crossmint);

        crossmintAddress = _crossmint;
    }

    function crossmint(address _to) external payable {
        require(price == msg.value, "Incorrect value sent");
        require(_tokenIdCounter.current() + 1 <= MAX_SUPPLY, "No more left");
        require(msg.sender == crossmintAddress, "This function is for Crossmint only.");

        uint256 newTokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(_to, newTokenId);

        emit OnlineMint(newTokenId);
    }

    function apiMint(address _to) external onlyRole(MINTER_ROLE) {
        uint256 newTokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(_to, newTokenId);

        emit InStoreMint(newTokenId);
    }

    function setPrice(uint256 _newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        price = _newPrice;
    }

    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(msg.sender).transfer(address(this).balance);
    }


    // ------------------------------
    // overrides required by Solidity
    // ------------------------------

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}