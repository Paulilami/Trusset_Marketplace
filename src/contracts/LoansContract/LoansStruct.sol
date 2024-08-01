// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface LoanStruct {
    
    enum LoanStatus { Inactive, Active, Completed }

     struct Loan {
        uint256 transactionCounter;
        bytes32 transactionIdentify;
        address borrower;
        address lender;
        address nftAddress;
        uint256 tokenId;
        uint256 initialPayment; 
        uint256 loanAmount; 
        uint256 totalLoanAmount; // loans amount + fees (FROM EXPAND LOAN)
        uint256 actualAmountPayed;
        uint256 interestRate; 
        uint256 endDate;
        uint256 startTime;
        uint256 lastPaymentTime;
        LoanStatus status;
        bool isExpanded;
        bool isCompleted;
        bool eligibleForFinancing;
        uint256 expandedDuration;
    }
}