// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

library LoanLibrary{
    function dailyInterestRateCalculator(uint interestRate, uint loanAmount )  internal pure returns(uint){
        return (loanAmount * interestRate)/(100*365);
    }

   function dailyPenaltyRateCalculator(uint penaltyRate, uint loanAmount, uint dailydelay) internal pure returns(uint){
        return loanAmount*(1 + (penaltyRate / 100 / 365)) ** (365 * dailydelay / 365);
    }
 
}

contract LoanLibraryContract{
     function calculateDailyInterest(uint interestRate,uint loanAmount) public pure returns (uint) {
        return LoanLibrary.dailyInterestRateCalculator(interestRate, loanAmount);
    }

    function calculateDailyPenalty(uint penaltyRate,uint loanAmount, uint dailydelay) public pure returns (uint) {
        return LoanLibrary.dailyPenaltyRateCalculator(penaltyRate, loanAmount, dailydelay);
    }
}