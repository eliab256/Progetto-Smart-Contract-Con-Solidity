
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LoanLibrary.sol";

contract LoanManager{

    //variables and structs
    enum LoanStatus{
        Active,
        Pending,
        Paid,
        Overdue
    }

    struct LoanBorrower{
        address borrowerAddress;
        uint8 creditScore;
        uint256[] userLoans;
    }

    struct Loan{
        uint256 loanId;
        LoanBorrower borrowerAddress;
        address lenderAddress;
        uint256 amount;
        uint256 interestRate; //in percentuale usando una scala di 100 es: 525 = 5,25%
        uint256 penaltyRate;
        uint256 startDate; //usare timestamp 
        uint256 dueDate;
        LoanStatus status;
    }

    uint256 private loanCounter;

    mapping(uint256 => Loan) public loansById;
    mapping(address => uint256[]) public userLoans;

    //events
    event LoanRequested(uint256 loanId, address borrower, uint256 amount, LoanStatus status);

    //functions
    function requestLoan(uint256 _amount, uint256 _daysOfLoan) public {
        //requires
        require(_amount > 0, "The loan amount must be greater than zero");
        require(-_daysOfLoan > 0, "The loan period must be grater than zero days");
        uint256[] memory loans = userLoans[msg.sender];

        for (uint i = 0; i < loans.length; i++) {
            uint256 loanId = loans[i];
            Loan memory userLoan = loansById[loanId];

        require(
            userLoan.status == LoanStatus.Paid, "You cannot request a new loan if you have pending, active, or overdue loans");
        }
        
        //actions
        loanCounter++;
        uint numberOfLoans = userLoans[msg.sender].length;
        uint borrowerCreditScore = LoanBorrower.creditScore;
        uint interestRateCalculation;
        
      
        if(numberOfLoans == 0){
            borrowerCreditScore = 1;
        }

        function getInterestRate(_daysOfLoan, borrowerCreditScore) private {
            
        }


        Loan memory newLoan = Loan({
            loanId: loanCounter,
            borrowerAddress: LoanBorrower(msg.sender, 1, userLoans + 1 ), // Inizializza il borrower con un credit score di 1 e un array vuoto
            lenderAddress: address(0),  // Nessun prestatore ancora assegnato
            amount: _amount,
            interestRate: 0,  
            penaltyRate: 0,  
            startDate: 0,  
            dueDate: 0,  
            status: LoanStatus.Pending 
        });

    };


}