// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "hardhat/console.sol";
import "./IEscrowForLoans.sol";

contract EscrowContract is IEscrow, IERC721Receiver {

    address public loanContract;
    mapping(uint256 => EscrowAccount) public escrowAccounts;

    struct EscrowAccount {
        address borrower;
        address lender;
        address nftAddress;
        uint256 tokenId;
        uint256 value;
        uint256 totalRepaid;
        bool isActive;
    }

    modifier onlyLoanContract() {
        require(msg.sender == loanContract, "Only loan contract can call this function");
        _;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function changeLoanContract(address _loanAddress) external {
        loanContract = _loanAddress;
    }

    function getBalance() external view  returns (uint) {
        return address(this).balance;
    }

    function depositNFT(address from, address nftAddress, uint256 tokenId, uint256 loanId, uint256 amount) external returns (bytes4) {
        require(!escrowAccounts[loanId].isActive, "This LoanId already exists");
        IERC721(nftAddress).transferFrom(from, address(this), tokenId);
        escrowAccounts[loanId] = EscrowAccount(
            from, 
            address(0), 
            nftAddress, 
            tokenId, 
            amount,
            0,
            true
        );
        emit NFTDeposited(nftAddress,tokenId, loanId, amount);
        return this.onERC721Received.selector;

    }

    function payLoan(address payable user, uint256 loanId) external payable  {
        EscrowAccount storage escrow = escrowAccounts[loanId];
        require(escrow.isActive, "This escrow account is not active");
        escrow.lender = user;
        escrow.totalRepaid += msg.value;
        emit LoanRepaid(loanId, escrow.lender, escrow.borrower,  msg.value);
    }

    function withdrawNFT(uint256 loanId, bool isDefaulted) public  {
        EscrowAccount memory account = escrowAccounts[loanId];
        if (isDefaulted) {
            IERC721(account.nftAddress).transferFrom(address(this), account.lender, account.tokenId);
            emit NFTWithdraw(loanId, account.lender, account.nftAddress, account.tokenId);
            delete escrowAccounts[loanId];
        } else {
            IERC721(account.nftAddress).transferFrom(address(this), account.borrower, account.tokenId);
            emit NFTWithdraw(loanId, account.borrower, account.nftAddress, account.tokenId);
            delete escrowAccounts[loanId];
        }
    }

    function withdrawERC20(uint256 loanId, bool isDefaulted) public  returns (bool) {
        EscrowAccount memory account = escrowAccounts[loanId];
        uint256 fee = isDefaulted ? (account.totalRepaid * 15 / 1000) : 0;

        if (isDefaulted) {
            (bool success1, ) = account.lender.call{value: fee}("");
            require(success1, "error fee not transferred");
            emit ERC20Withdraw(loanId, account.lender, fee);

            (bool success2, ) = account.borrower.call{value: account.totalRepaid - fee}("");
            require(success2, "error value not transferred");
            emit ERC20Withdraw(loanId, account.borrower, account.totalRepaid - fee);

            return success1 && success2;
        } else {
            (bool success, ) = account.lender.call{value: account.totalRepaid}("");
            require(success, "error success, totalRepaid not transferred");
            emit ERC20Withdraw(loanId, account.lender, account.totalRepaid);
            return success;
        }
    }
}
