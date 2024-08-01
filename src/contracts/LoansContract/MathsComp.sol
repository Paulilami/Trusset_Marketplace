// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

abstract contract MathsComp {
    
    uint256 public constant SECONDS_IN_DAY = 86400;
    uint256 public MAX_INTEREST_RATE = 6; // 6%
    uint256 public MAX_DURATION = 3 * 365 days; // 3 years
    uint256 public MIN_DURATION = 30 days; // 1 month
    uint256 public MIN_DOWN_PAYMENT_PERCENTAGE = 2;
    uint256 public MAX_DOWN_PAYMENT_PERCENTAGE = 80;
    uint256 public LIQUIDATION_FEE_PERCENTAGE = 1;
    uint256 public PENALTY_RATE_PER_MONTH = 25; // 0.25% per month
    uint256 penaltyRate;
    uint256 private counterItemsLoan = 1;

    constructor() {}



    // DEFAULTED FUNCTIONS
    
    function setMaxInterestRate(uint256 newMaxInterestRate) external {
        MAX_INTEREST_RATE = newMaxInterestRate;
    }

    function setMaxDuration(uint256 newMaxDuration) external {
        MAX_DURATION = newMaxDuration;
    }

    function setMinDuration(uint256 newMinDuration) external {
        MIN_DURATION = newMinDuration;
    }

    function setMinDownPaymentPercentage(uint256 newMinDownPaymentPercentage) external {
        MIN_DOWN_PAYMENT_PERCENTAGE = newMinDownPaymentPercentage;
    }

    function setMaxDownPaymentPercentage(uint256 newMaxDownPaymentPercentage) external {
        MAX_DOWN_PAYMENT_PERCENTAGE = newMaxDownPaymentPercentage;
    }

    function setLiquidationFeePercentage(uint256 newLiquidationFeePercentage) external {
        LIQUIDATION_FEE_PERCENTAGE = newLiquidationFeePercentage;
    }

    function setPenaltyRatePerMonth(uint256 newPenaltyRatePerMonth) external {
        PENALTY_RATE_PER_MONTH = newPenaltyRatePerMonth;
    }
}