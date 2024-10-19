
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

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
    uint16  private constant daysOfLoan = 365;

    mapping(uint256 => Loan) public loansById;  //create a inex to tracks every loan
    uint256[] public pendingLoansByAmount; //all the pending loan in order to amount
    uint256[] public pendingLoansByInterestRate; //all the pending loans inj order to interest rate
    mapping(address => LoanBorrower) public loanBorrowers; //create an index tp track every borrower with his history of loans
    mapping(address => uint256[]) public userLoans; //update the borrower struct with all his loan.

    //events
    event LoanRequested(uint256 loanId, address indexed borrower, uint256 indexed amount, LoanStatus status, uint256 indexed interestRate );

    //functions

    //private and internal functions

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

    function updatePendingLoansByAmount(uint256 _amount) private {
        uint256 i = 0;
        while(i < pendingLoansByAmount.length && pendingLoansByAmount[i] >= _amount){
            i++;
        }
        pendingLoansByAmount.push(_amount);
        for (uint256 j = pendingLoansByAmount.length - 1; j > i; j--) {
            pendingLoansByAmount[j] = pendingLoansByAmount[j - 1];
        }
        pendingLoansByAmount[i] = _amount;
    }

    function updatePendingLoansByInterestRate(uint256 _interestRate) private{
        uint256 i = 0;
        while(i < pendingLoansByInterestRate.length && pendingLoansByInterestRate[i] >= _interestRate){
            i++;
        }
        pendingLoansByInterestRate.push(_interestRate);
        for (uint256 j = pendingLoansByInterestRate.length - 1; j > i; j--) {
            pendingLoansByInterestRate[j] = pendingLoansByInterestRate[j - 1];
        }
        pendingLoansByInterestRate[i] = _interestRate;
    }

    function addNewLoan(Loan memory _loan) private {
        loansById[_loan.loanId] = _loan;
        userLoans[_loan.borrowerAddress.borrowerAddress].push(_loan.loanId);
        updatePendingLoansByAmount(_loan.amount);
        updatePendingLoansByInterestRate(_loan.interestRate);     
    }


    //borrower functions
    
    function requestLoan(uint256 _amount) public {
        //requires
        require(_amount > 0, "The loan amount must be greater than zero");
        uint256[] memory loans = userLoans[msg.sender];

        for (uint i = 0; i < loans.length; i++) {
            uint256 loanId = loans[i];
            Loan memory userLoan = loansById[loanId];

        require(
            userLoan.status == LoanStatus.Paid, "You cannot request a new loan if you have pending, active, or overdue loans");
        }
        
        loanCounter++;
        uint numberOfLoans = userLoans[msg.sender].length;
        uint8 borrowerCreditScore = (numberOfLoans == 0) ? 1 : loanBorrowers[msg.sender].creditScore;

        (uint256 annualizedInterestRate, uint256 annualizedPenaltyRate) = loanInterestCalculator(borrowerCreditScore);

        Loan memory newLoan = Loan({
            loanId: loanCounter,
            borrowerAddress: LoanBorrower(msg.sender, borrowerCreditScore, userLoans[msg.sender]), 
            lenderAddress: address(0),  
            amount: _amount,
            interestRate: annualizedInterestRate,  
            penaltyRate: annualizedPenaltyRate,  
            startDate: 0,  
            dueDate: 0,  
            status: LoanStatus.Pending 
        });

        addNewLoan(newLoan);

        emit LoanRequested(loanCounter, msg.sender, _amount, LoanStatus.Pending, annualizedInterestRate);        

    }

    //lender functions
    function getPendingLoanByAmount() public view returns (uint256[] memory) { //lender can see all the pending loan in order to amount 
        return pendingLoansByAmount; 
    }

     function getPendingLoanByInterestRate() public view returns (uint256[] memory) { //lender can see all the pending loan in order to interest rate 
        return pendingLoansByInterestRate; 
    }



}