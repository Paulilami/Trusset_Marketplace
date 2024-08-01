// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";




contract MarketplaceNew is ReentrancyGuard {
    
    // using Counters for Counters.Counter;
    // Counters.Counter public _itemIds;
    // Counters.Counter public _itemsSold;

    address public _tokenAddress;
    address public _creator;
    IERC721  public _tokenContract;
    ERC721   public _tokenContractERC20;

    uint256 standardPrice = 1 wei;
    uint256 private counterItemsListing = 1;

    uint256 [] public itemsId;
    string []  itemsIdString;

    mapping(address => Listing) public itemsListingByAddress;
    mapping(string => Listing) public itemsListingByString;
    mapping(uint256 => Listing) public itemsListingByUint256;   
    mapping(bytes32 => Listing) public itemsListingByte32;     
    mapping(uint256 => mapping(uint256 => uint256)) public ownedItemsSTO;
    mapping(bytes32 => bool) itemsIdExist;
    mapping(address => mapping(bytes32 => uint256)) public ownedItemsSTOItemId;
    mapping(address => bool) public whitelist;

    bytes32[] public listingsIndex;

    struct Listing {
        uint256 transactionCounter;
        bytes32 transactionIdentify;
        IERC721 contractAddress721;
        uint256 tokenId;
        uint256 quantity;
        uint256 price;
        address creator;
        address payable seller;
        address owner;
        bool sold;
        //    bool FinancingEnabled;
        //    IERC1155 contractAddress1155;
        //    bool isERC721;
    }

    // Eventi
    event TokenListed(address indexed tokenContract, uint256 indexed tokenId, uint256 quantity, uint256 price, address indexed seller);
    event TokenSold(address indexed tokenContract, uint256 indexed tokenId, uint256 quantity, uint256 price, address indexed buyer);
    event TokenRemoved(address indexed tokenContract, uint256 indexed tokenId, uint256 quantity, address indexed seller);

    modifier onlySeller(uint256 listingId) {
        require(itemsListingByUint256[listingId].seller == msg.sender, "Not the seller");
        _;
    }
     constructor() 
    {}

    function removeToken(uint256 itemId) private returns (bool) {
        Listing storage ItemListed = itemsListingByUint256[itemId];

        delete itemsListingByUint256[itemId];
            
        emit TokenRemoved(address(ItemListed.contractAddress721), ItemListed.tokenId, ItemListed.quantity, msg.sender);
        counterItemsListing--;
        return true;
    }

    function removeTokenBySeller(uint256 itemId) onlySeller(itemId) external returns (bool) {
        Listing storage ItemListed = itemsListingByUint256[itemId];
        require(ItemListed.seller == msg.sender, "You are not allowed, only the seller can revoke the listing");
        IERC721(ItemListed.contractAddress721).safeTransferFrom(address(this), ItemListed.seller, ItemListed.tokenId);
        //emit TokenRemoved(ItemListed.contractAddress721, ItemListed.tokenId, ItemListed.quantity, msg.sender);
        delete itemsListingByUint256[itemId];
        return true;
    }

    function generateRandomCode() private returns (bytes32) {
            bytes32 randomBytes = keccak256(abi.encodePacked(block.timestamp, msg.sender));
            return bytes32(randomBytes);
    }

    function bytes32ToString(bytes32 _bytes32) private pure returns (bytes32) {
        uint8 i = 0;
        bytes memory bytesArray = new bytes(32);
        for (i = 0; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return bytes32(bytesArray);
    }
    // Funzione per elencare un token
     function listToken(address tokenContract, uint256 tokenId, uint256 quantity, uint256 price) external {
        bytes32 newTransactionIdentify = generateRandomCode();
        require(bytes32(newTransactionIdentify).length > 0, "Invalid item ID");
        require(!itemsIdExist[newTransactionIdentify], "newTransactionIdentify already stored");
        require(price >= 0, "Price must be greater than zero");
        require(quantity > 0, "Quantity must be greater than zero");
        bytes32 listingId = keccak256(abi.encodePacked(tokenContract, tokenId, msg.sender));

        IERC721 erc721 = IERC721(tokenContract);
        //require(erc721.ownerOf(tokenId) == msg.sender, "Not the owner");

        require(erc721.balanceOf(msg.sender) >= quantity, "Insufficient balance");
        erc721.transferFrom(msg.sender, address(this), tokenId);

        // _itemIds.increment();
        // uint256 itemId = _itemIds.current();
        // itemsId.push(itemId);

        itemsListingByUint256[counterItemsListing] = Listing({
            transactionCounter: counterItemsListing,
            transactionIdentify : newTransactionIdentify,
            contractAddress721: IERC721(tokenContract),
            tokenId: tokenId,
            quantity: quantity,
            price: price,
            creator: erc721.ownerOf(tokenId),
            seller: payable(msg.sender),
            owner: msg.sender,
            sold: false
        });
        counterItemsListing++;
        ownedItemsSTOItemId[msg.sender][newTransactionIdentify] = quantity;
        itemsIdExist[newTransactionIdentify] = true;

        listingsIndex.push(listingId);

        emit TokenListed(tokenContract, tokenId, quantity, price, msg.sender);
    }

    function buyToken(uint256 itemId) external payable {
        Listing storage ItemListed = itemsListingByUint256[itemId];
        require(ItemListed.seller != address(0), "Listing not found");

        require(msg.value >= ItemListed.price, "Insufficient funds");

        ItemListed.contractAddress721.approve(msg.sender, ItemListed.tokenId);
        ItemListed.contractAddress721.transferFrom(address(this), msg.sender, ItemListed.tokenId);
        
        payable(ItemListed.seller).transfer(ItemListed.price);
    
        // Rimuovi il token dalla lista
        //emit TokenSold(ItemListed.tokenContract, ItemListed.tokenId, ItemListed.quantity, ItemListed.price, msg.sender);
        
        // itemsListingByUint256[itemId] = Listing(     
        //     ItemListed.transactionCounter,
        //     ItemListed.transactionIdentify,
        //     ItemListed.contractAddress721,
        //     ItemListed.tokenId,
        //     ItemListed.quantity,
        //     ItemListed.price,
        //     ItemListed.creator,
        //     ItemListed.seller,
        //     ItemListed.owner,
        // true );

        delete itemsListingByUint256[itemId];
        
    }


    function getAllListingsIndex() external view returns (bytes32[] memory) {
        return listingsIndex;
    }

    function listingsCount() public view returns (uint256) {
        return listingsIndex.length;
    }

    function removeFromListingsIndex(bytes32 listingId) private {
        for (uint256 i = 0; i < listingsIndex.length; i++) {
            if (listingsIndex[i] == listingId) {
                if (i < listingsIndex.length - 1) {
                    listingsIndex[i] = listingsIndex[listingsIndex.length - 1];
                }
                listingsIndex.pop();
                break;
            }
        }
    }

    function getAllListings() external view returns (Listing[] memory) {
        Listing[] memory allListings = new Listing[](counterItemsListing);

        for (uint256 i = 0; i < counterItemsListing; i++) {
            allListings[i] = itemsListingByUint256[i];
        }

        return allListings;
    }
}
