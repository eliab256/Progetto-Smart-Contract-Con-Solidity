// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LoanLibrary{
    function dailyInterestRateCalculator(uint interestRate, uint loanAmount )  internal pure returns(uint){
        uint dailyInterestRate = (loanAmount * interestRate)/(100*365);
        return dailyInterestRate;
    }

    function dailyPenaltyRateCalculator(uint penaltyRate, uint loanAmount, uint dailydelay) internal pure returns (uint) {
        uint penaltyAmount = (loanAmount * penaltyRate * dailydelay) / (100 * 365);
        return penaltyAmount;
    }
 
}

contract LoanLibraryContract {
    function calculateDailyInterest(uint interestRate, uint loanAmount) public pure returns (uint) {
        return LoanLibrary.dailyInterestRateCalculator(interestRate, loanAmount);
    }

    function calculateDailyPenalty(uint penaltyRate, uint loanAmount, uint dailydelay) public pure returns (uint) {
        return LoanLibrary.dailyPenaltyRateCalculator(penaltyRate, loanAmount, dailydelay);
    }
}