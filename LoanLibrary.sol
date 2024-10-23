// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library LoanLibrary{
    function interestCalculator(uint annualInterestRate, uint loanAmount, uint daysOfLoan)  internal pure returns(uint){
        uint256 dailyInterestRate = annualInterestRate / 100 / 365;

        for (uint256 i = 0; i < daysOfLoan; i++) {
        loanAmount = loanAmount + (loanAmount * (dailyInterestRate/100));
    }

    return loanAmount; 
    }

    function penaltyCalculator(uint annualPenaltyRate, uint loanAmount, uint daysOfDelay) internal pure returns (uint) {
        uint256 dailyPenaltyRate = annualPenaltyRate / 100 / 365;

        for (uint256 i = 0; i < daysOfDelay; i++) {
        loanAmount = loanAmount + (loanAmount * (dailyPenaltyRate/100));
    }

    return loanAmount; 
    }
 
}
 
contract LoanLibraryContract {
    function interestCalculator(uint interestRate, uint loanAmount, uint daysOfLoan) public pure returns (uint) {
        return LoanLibrary.interestCalculator(interestRate, loanAmount, daysOfLoan);
    }

    function penaltyCalculator(uint penaltyRate, uint loanAmount, uint daysOfDelay) public pure returns (uint) {
        return LoanLibrary.penaltyCalculator(penaltyRate, loanAmount, daysOfDelay);
    }
}