// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILoansContractNew {

    event LoanListed(address indexed tokenContract, uint256 indexed tokenId, uint256 quantity, uint256 price, address indexed seller);
    event LoanCreated(uint256 indexed loanId, address indexed borrower, address indexed lender, uint256 loanAmount, uint256 duration);
    event LoanPaymentMade(uint256 indexed loanId, uint256 amount);
    event LoanDurationExpanded(uint256 indexed loanId, uint256 additionalDuration);
    event LoanCompleted(uint256 indexed loanId);
    event LoanDefaulted(uint256 indexed loanId);

    function createLoan(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _price,
        uint256 _duration,
        uint256 _interestRate,
        uint256 _downPayment,
        uint256 ID,
        bool _eligibleForFinancing
    ) external returns (address);

    function setAssetRegister(address _address) external returns(bool);

    function startLoan(uint256 loanId) external payable;

    function collectPayment(uint256 loanId) external payable;

    function WithdrawNFT(uint256 loanId, bool defaulted) external;

    function WithdrawERC20(uint256 loanId, bool defaulted) external;

    function setEscrowContract(address contractAddress) external;

    function expandLoanDuration(uint256 loanId, uint256 additionalDuration, uint256 penaltyAmount) external payable;

}
