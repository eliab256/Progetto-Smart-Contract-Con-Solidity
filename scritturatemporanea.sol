pragma solidity ^0.8.0;

contract LoanContract {
    // Definizione dell'evento
    event LoanRequested(
        address borrower, 
        uint256 amount, 
        uint256 daysOfLoan, 
        uint256 indexed interestRate, 
        uint256 penaltyRate
    );

    // Funzione per calcolare il tasso di interesse
    function loanInterestCalculator(uint8 _borrowerCreditScore) private pure returns (uint256, uint256) {
        uint256 annualizedInterestRate;
        uint256 annualizedPenaltyRate;

        if (_borrowerCreditScore == 0) {
            annualizedInterestRate = 2000; // 20%
            annualizedPenaltyRate = 3000;  // 30%
        } 
        else if (_borrowerCreditScore == 1) {
            annualizedInterestRate = 1200; // 12%
            annualizedPenaltyRate = 2000;  // 20%
        } 
        else if (_borrowerCreditScore == 2) {
            annualizedInterestRate = 1000; // 10%
            annualizedPenaltyRate = 1500;  // 15%
        }  
        else if (_borrowerCreditScore == 3) {
            annualizedInterestRate = 800;  // 8%
            annualizedPenaltyRate = 1300;  // 13%
        } 
        else if (_borrowerCreditScore >= 4) {  
            annualizedInterestRate = 600;  // 6%
            annualizedPenaltyRate = 900;   // 9%
        }

        return (annualizedInterestRate, annualizedPenaltyRate);
    }

    function requestLoan(uint256 _amount, uint256 _daysOfLoan) public {
        // Requires
        require(_amount > 0, "The loan amount must be greater than zero");
        require(_daysOfLoan > 0, "The loan period must be greater than zero days"); // Corretto

        uint256[] memory loans = userLoans[msg.sender];

        for (uint i = 0; i < loans.length; i++) {
            uint256 loanId = loans[i];
            Loan memory userLoan = loansById[loanId];

            require(
                userLoan.status == LoanStatus.Paid, 
                "You cannot request a new loan if you have pending, active, or overdue loans"
            );
        }

        loanCounter++;
        uint numberOfLoans = userLoans[msg.sender].length;
        uint8 borrowerCreditScore = LoanBorrower.creditScore; // Assicurati che LoanBorrower sia accessibile

        if (numberOfLoans == 0) {
            borrowerCreditScore = 1;
        }

        // Chiamata alla funzione loanInterestCalculator e destrutturazione dei risultati
        (uint256 interestRate, uint256 penaltyRate) = loanInterestCalculator(borrowerCreditScore);
        
        // Emit dell'evento con i parametri desiderati
        emit LoanRequested(msg.sender, _amount, _daysOfLoan, interestRate, penaltyRate);
    }
}
