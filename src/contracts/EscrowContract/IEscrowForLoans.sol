// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEscrow {
    function changeLoanContract(address _loanAddress) external;
    function getBalance() external view returns (uint);
    function depositNFT(address from, address nftAddress, uint256 tokenId, uint256 loanId, uint256 amount) external returns (bytes4);
    function payLoan(address payable caller, uint256 loanId) external payable;
    function withdrawNFT(uint256 loanId, bool isDefaulted) external;
    function withdrawERC20(uint256 loanId, bool isDefaulted) external returns (bool);

    event LoanContractChanged(address indexed newLoanContract);
    event NFTDeposited(address indexed nftAddress, uint256 indexed tokenId, uint256 indexed loanId, uint256 amount);
    event LoanRepaid(uint256 indexed loanId, address indexed lender, address indexed borrower, uint256 amount);
    event NFTWithdraw(uint256 indexed loanId, address indexed to, address indexed nftAddress, uint256 tokenId);
    event ERC20Withdraw(uint256 indexed loanId, address indexed to, uint256 amount);
}

