// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../AssetRegister.sol";
import "./IEscrowForLoans.sol";
import "./LoansStruct.sol";
import "./MathsComp.sol";
import "./ILoansContractNew.sol";
import "hardhat/console.sol";

contract LoansContractNew is AssetRegister,ILoansContractNew, LoanStruct{

    address contractAssetRegister;
    IEscrow public escrowContract;
    uint256 counterItemsLoan = 1;
    mapping(uint256 => Loan) private loans;
    mapping(bytes32 => bool) private itemsIdExist;
    mapping(address => mapping(bytes32 => uint256)) internal ownedItemsLoantemId;

    constructor() {}
    
    function generateRandomCode() private view returns (bytes32) {
        bytes32 randomBytes = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        return bytes32(randomBytes);
    }
    
    function createLoan (
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _price,
        uint256 _endDate,
        uint256 _interestRate,
        uint256 _downPayment,
        uint256 ID, 
        bool _eligibleForFinancing
    ) public returns (address) {

        bytes32 newTransactionIdentify = generateRandomCode();
        require(!itemsIdExist[newTransactionIdentify], "Transaction already exists");
        require(_price > 0, "Price must be greater than zero");

        escrowContract.depositNFT(msg.sender, _nftAddress, _tokenId, ID, _price); // transfer the NFT to the ESCROW CONTRACT
        loans[ID] = Loan({
            transactionCounter: counterItemsLoan,
            transactionIdentify: newTransactionIdentify,
            borrower: address(0),
            lender: msg.sender,
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            initialPayment:  _downPayment, // 100 for test
            loanAmount: _price,
            totalLoanAmount: _price,
            actualAmountPayed: 0,
            interestRate:_interestRate,
            endDate: _endDate,
            startTime: 0,
            lastPaymentTime: 0,
            status: LoanStatus.Inactive,
            isExpanded: false,
            isCompleted: false,
            eligibleForFinancing: _eligibleForFinancing,
            expandedDuration: 0
        });

        counterItemsLoan++;
        // IAssetRegister(contractAssetRegister).registerAsset(_nftAddress, _tokenId); // TO UPDATE LATER
        ownedItemsLoantemId[msg.sender][newTransactionIdentify] = _quantity; // I don't know if it's still usefull
        itemsIdExist[newTransactionIdentify] = true;
        emit LoanListed(_nftAddress, _tokenId, _quantity, _price, msg.sender);
        return tx.origin;
       
    }

    function setAssetRegister(address _address) external returns(bool) {
        contractAssetRegister = _address;
        return true;
    }

    function startLoan(uint256 loanId) public payable {
        Loan storage loan = loans[loanId];
        require(loan.borrower == address(0), "Loan already started");
        require(loan.status == LoanStatus.Inactive, "Loan already started");
        require(msg.value >= loan.initialPayment, "Wrong initial payment");
        escrowContract.payLoan{value: msg.value}(payable(msg.sender), loanId);
        loan.borrower = msg.sender;
        loan.actualAmountPayed = loan.initialPayment;
        loan.status = LoanStatus.Active;
        loan.startTime = block.timestamp;
        loan.lastPaymentTime = block.timestamp;

        emit LoanCreated(loanId, msg.sender, loan.lender, loan.initialPayment, loan.endDate);
    }

    function collectPayment(uint256 loanId) public payable {
        Loan storage loan = loans[loanId];
        require(loan.status == LoanStatus.Active, "Loan not active");
        require(msg.sender == loan.borrower, "Only borrower can make payment");
        require(msg.value >= loan.interestRate, "Insufficient payment");
        escrowContract.payLoan{value: msg.value}(payable(msg.sender), loanId);

        loan.actualAmountPayed += msg.value;
        loan.lastPaymentTime = block.timestamp;

        if (loan.actualAmountPayed >= loan.totalLoanAmount) {
            console.log("actualAmountPayed:", loan.actualAmountPayed, "totalLoanAmount:", loan.totalLoanAmount);
            this.WithdrawERC20(loanId, true);
            this.WithdrawNFT(loanId, true);
            delete loans[loanId];
        }

        emit LoanPaymentMade(loanId, msg.value);
    }

    function WithdrawNFT (uint256 loanId, bool defaulted) external{
        escrowContract.withdrawNFT(loanId, defaulted);
    }

    function WithdrawERC20 (uint256 loanId, bool defaulted) external{
        escrowContract.withdrawERC20(loanId, defaulted);
    }

    function setEscrowContract (address contractAddress) external{
        escrowContract = IEscrow(contractAddress);
    }

    function expandLoanDuration(uint256 loanId, uint256 newDate, uint256 penaltyAmount) public payable  {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.borrower, "Only the borrower can expand the loan duration");
        require(!loan.isCompleted, "Loan is already completed");
        require(!loan.isExpanded, "Loan duration has already been expanded");
       
        require(msg.value <= penaltyAmount, "penality not payed" );
        escrowContract.payLoan{value: msg.value}(payable(msg.sender), loanId);

        loan.totalLoanAmount += penaltyAmount;
        loan.actualAmountPayed += msg.value;
        loan.endDate += newDate;
        loan.isExpanded = true;
        loan.expandedDuration = newDate;

    }

    function getAllLoans() external view returns (Loan[] memory) {
        Loan[] memory allLoans = new Loan[](counterItemsLoan - 1);

        for (uint256 i = 1; i < counterItemsLoan; i++) {
            allLoans[i - 1] = loans[i];
        }

        return allLoans;
    }

    function getLoanById(uint256 loanId) external view returns (Loan memory) {
        Loan storage loan = loans[loanId];
        return loan;
    }

}