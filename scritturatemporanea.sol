// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library LoanLibrary {
    function interestCalculator(uint256 annualInterestRate, uint256 loanAmount, uint256 daysOfLoan) internal pure returns (uint256) {
        uint256 dailyInterestRate = (annualInterestRate / 100) / 365;
        uint256 compoundedAmount = loanAmount * (100 + dailyInterestRate)**daysOfLoan / (100**daysOfLoan);
        return compoundedAmount;
    }

    function penaltyCalculator(uint256 annualPenaltyRate, uint256 loanAmount, uint256 daysOfDelay) internal pure returns (uint256) {
        uint256 dailyPenaltyRate = (annualPenaltyRate / 100) / 365;
        uint256 compoundedPenaltyAmount = loanAmount * (100 + dailyPenaltyRate)**daysOfDelay / (100**daysOfDelay);
        return compoundedPenaltyAmount;
    }
}

contract LoanLibraryContract {
    function calculateDailyInterest(uint256 interestRate, uint256 loanAmount, uint256 daysOfLoan) 
        public 
        pure 
        returns (uint256) 
    {
        return LoanLibrary.interestCalculator(interestRate, loanAmount, daysOfLoan);
    }

    function calculateDailyPenalty(uint256 penaltyRate, uint256 loanAmount, uint256 daysOfDelay) 
        public 
        pure 
        returns (uint256) 
    {
        return LoanLibrary.penaltyCalculator(penaltyRate, loanAmount, daysOfDelay);
    }
}
