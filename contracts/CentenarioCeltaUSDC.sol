// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CentenarioCelta is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter;
    using Strings for uint256;

    event InStoreMint(uint256 tokenId);
    event OnlineMint(uint256 tokenId);

    Counters.Counter private _tokenIdCounter;

    IERC20 public usdc;
    uint256 public constant MAX_SUPPLY = 500;
    uint256 price = 10 ether; // 10 MATIC
    uint256 priceUSDC = 10 * 10 ** 6; // 10 USDC (because usdc is a 6 decimal ERC20 token)
    string public baseUri = "https://bafkreihgonrtu7xig2elazkhyd424uozpe2zs35gdhd6my4sgskpsaij7i.ipfs.nftstorage.link/";

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public crossmintAddress;

    constructor(address _crossmint, address _usdcAddress) ERC721("Centenario Celta", "CLT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _crossmint);

        crossmintAddress = _crossmint;

        // set USDC token contract address
        usdc = IERC20(_usdcAddress);
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

    function crossmintUSDC(address _to) external {
        require(_tokenIdCounter.current() + 1 <= MAX_SUPPLY, "No more left");
        require(msg.sender == crossmintAddress, "This function is for Crossmint only.");

        usdc.transferFrom(msg.sender, address(this), priceUSDC);

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

    function setPriceUSDC(uint256 _newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        priceUSDC = _newPrice;
    }

    function setCrossmintAddress(address _crossmintAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        crossmintAddress = _crossmintAddress;
    }

    function setUsdcAddress(IERC20 _usdc) public onlyRole(DEFAULT_ADMIN_ROLE) {
        usdc = _usdc;
    }

    function setUri(string calldata _newUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseUri = _newUri;
    }

    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawUSDC() public onlyRole(DEFAULT_ADMIN_ROLE) {
        usdc.transfer(msg.sender, usdc.balanceOf(address(this)));
    }


    // ------------------------------
    // ERC-721 Overrides
    // ------------------------------

    function tokenURI(uint256 /*tokenId*/)
        public
        view
        override
        returns (string memory)
    {
        return baseUri;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);
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