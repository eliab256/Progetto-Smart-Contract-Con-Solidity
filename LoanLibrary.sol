// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LoanLibrary{
    function interestCalculator(uint annualInterestRate, uint loanAmount, uint daysOfLoan)  internal pure returns(uint){
        uint scalingFactor = 100000;
       
        loanAmount = loanAmount * (scalingFactor + ((annualInterestRate * daysOfLoan * scalingFactor)/365)) / scalingFactor ;
    
        return loanAmount; 
    }

    function penaltyCalculator(uint annualPenaltyRate, uint loanAmount, uint daysOfDelay) internal pure returns (uint) {
        uint scalingFactor = 100000;
       
        loanAmount = loanAmount * (scalingFactor + ((annualPenaltyRate * daysOfDelay * scalingFactor)/365)) / scalingFactor ;   

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