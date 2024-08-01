// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

abstract contract IAssetRegister {

    enum TokenStandard { ERC20, ERC721, ERC1155 }
    //enum AssetState { Available, ActiveListing, ActiveLoan, ActiveVault, Locked, Transferred }
    //enum PaymentStreamState { None, ActivePayments }
    
    /*
    roles for access control, needed for compliance 
    admin role --> can make changes in the register (legal entities, us)
    verifier role --> allows to deploy assets  in register without off-chain verification (if algorithm fails) 
   
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    */

    struct Asset {
        address contractAddress;
        uint256 tokenId;
        TokenStandard tokenStandard;
        address owner;
        uint256 date;
        //AssetState state; --> current state of the asset
        //uint256 contractId; // ID of the contract managing the asset (vault, loan, etc.)
        //...payment stream state & ID
    }

    function registerAsset(address _contractAddress, uint256 _tokenId) external virtual returns (bool);
    function getAsset(bytes32 _assetId) public view virtual returns (Asset memory);
    function deleteAsset(bytes32 _assetId) public virtual returns (bool);
    function getAllRegisteredAssets() public virtual returns (Asset[] memory);
    function getAllAssetIds() public view virtual returns (bytes32[] memory);
}

contract AssetRegister is IAssetRegister {

    mapping(bytes32 => Asset) private registeredAssets;
    bytes32[] private assetIds;

    //address[] public vaultContracts; --> store the contract addresses within an array for flexibility, in case we have more contracts to be connected.
    //address[] public listingContracts;
    //address[] public loanContracts;

    event AssetRegistered(bytes32 assetId, Asset asset);

    /*
    better logging for compliance 

    event AssetStateUpdated(bytes32 assetId, AssetState newState, uint256 contractId, uint256 timestamp);
    event AssetDeleted(bytes32 assetId, address owner, uint256 timestamp);
    */

    function registerAsset(address _contractAddress, uint256 _tokenId) external override returns (bool) {
        require(_contractAddress != address(0), "Invalid contract address");

        bytes32 assetId = keccak256(abi.encodePacked(_contractAddress, _tokenId));

        require(registeredAssets[assetId].contractAddress == address(0), "Asset already registered");

        if (isERC721(_contractAddress)) {
            registeredAssets[assetId] = Asset(_contractAddress, _tokenId, TokenStandard.ERC721, msg.sender, block.timestamp);
        } else if (isERC1155(_contractAddress)) {
            registeredAssets[assetId] = Asset(_contractAddress, _tokenId, TokenStandard.ERC1155, msg.sender, block.timestamp);
        } else {
            revert("Unsupported contract");
        }

        assetIds.push(assetId);
        emit AssetRegistered(assetId, registeredAssets[assetId]);
        return true;
    }

    function deleteAsset(bytes32 _assetId) public override returns (bool) {
        require(registeredAssets[_assetId].contractAddress != address(0), "Asset not found");
        // require(msg.sender == registeredAssets[_assetId].owner, "Not authorized");


        for (uint i = 0; i < assetIds.length; i++) {
            if (assetIds[i] == _assetId) {
                assetIds[i] = assetIds[assetIds.length - 1];
                assetIds.pop();
                break;
            }
        }
        
        delete registeredAssets[_assetId];
        return true;
    }

    function isERC721(address _contractAddress) internal view returns (bool) {
        try IERC721(_contractAddress).supportsInterface(0x80ac58cd) returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    function isERC1155(address _contractAddress) internal view returns (bool) {
        try IERC1155(_contractAddress).supportsInterface(0xd9b67a26) returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    function getAsset(bytes32 _assetId) public view override returns (Asset memory) {
        return registeredAssets[_assetId];
    }

    function getAllRegisteredAssets() public view override returns (Asset[] memory) {
        Asset[] memory assets = new Asset[](assetIds.length);
        for (uint i = 0; i < assetIds.length; i++) {
            assets[i] = registeredAssets[assetIds[i]];
        }
        return assets;
    }

    function getAllAssetIds() public view override returns (bytes32[] memory){
        return assetIds;
    }
}
