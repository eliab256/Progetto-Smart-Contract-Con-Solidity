// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LoanLibrary.sol";

contract LoanManager {

    // Enum to represent loan statuses
    enum LoanStatus {
        Active,
        Pending,
        Paid,
        Overdue,
        Canceled
    }

    enum LoanDuration{
        Month,
        SixMonths,
        Year
    }

    // Struct to represent a borrower and his loans
    struct LoanBorrower {
        address borrowerAddress;
        uint8 creditScore;
        uint256[] loanHistory;
    }

    // Struct to represent a loan
    struct Loan {
        uint256 loanId;
        LoanBorrower borrower;
        address lender;
        uint256 amount;
        uint256 interestRate; // in percent (use a scale of 100, e.g., 525 = 5.25%)
        uint256 penaltyRate;
        uint256 startDate; // timestamp
        uint256 dueDate;
        LoanStatus status;
        LoanDuration duration;
    }

    uint256 private loanCounter;

    // Mappings to track loans and borrowers
    mapping(uint256 => Loan) public loansById;  // Tracks each loan by its ID
    mapping(address => LoanBorrower) public loanBorrowers; // Tracks each borrower with their loan history
    mapping(address => uint256[]) public borrowerLoans; // Tracks loans by borrower address

    // Events
    event LoanRequested(uint256 loanId, address indexed borrower, uint256 indexed amount, LoanStatus status, uint256 indexed interestRate, LoanDuration duration);
    event LoanFunded(uint256 loanId, address lender, address borrower, uint256 amount, uint256 startDate, uint256 dueDate);
    event LoanCanceled(uint256 loanId, address indexed borrower, uint256 indexed amount, LoanStatus previousStatus);
    event LoanExpiration(uint256 loanId, address indexed borrower, uint256 indexed amount, LoanStatus previousStatus, uint8 borrowerCreditScore);
    event LoanOverdue(uint256 loanId, address indexed borrower, uint256 indexed amount, LoanStatus previousStatus, uint8 borrowerCreditScore, uint daysOfDelay);

    // Private and internal functions

    function getPendingLoansArray() private view returns (Loan[] memory, uint256) {
        uint256 pendingLoanCount = 0;

        for (uint256 i = 1; i <= loanCounter; i++) {
            if (loansById[i].status == LoanStatus.Pending) {
                pendingLoanCount++;
            }
        }

        Loan[] memory pendingLoans = new Loan[](pendingLoanCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= loanCounter; i++) {
            if (loansById[i].status == LoanStatus.Pending) {
                pendingLoans[index] = loansById[i];
                index++;
            }
        }

        return (pendingLoans, pendingLoanCount);
    }

    function loanInterestRateCalculator(uint8 _creditScore) private pure returns (uint256, uint256) {
        require(_creditScore <= 4, "Invalid credit score"); // Maximum credit score is 4
        uint256 annualizedInterestRate;
        uint256 annualizedPenaltyRate;

        if (_creditScore == 0) {
            annualizedInterestRate = 2000; // 20%
            annualizedPenaltyRate = 3000;  // 30%
        } 
        else if (_creditScore == 1) {
            annualizedInterestRate = 1200; // 12%
            annualizedPenaltyRate = 2000;  // 20%
        } 
        else if (_creditScore == 2) {
            annualizedInterestRate = 1000; // 10%
            annualizedPenaltyRate = 1500;  // 15%
        }  
        else if (_creditScore == 3) {
            annualizedInterestRate = 800;  // 8%
            annualizedPenaltyRate = 1300;  // 13%
        } 
        else if (_creditScore >= 4) {  
            annualizedInterestRate = 600;  // 6%
            annualizedPenaltyRate = 900;   // 9%
        }

        return (annualizedInterestRate, annualizedPenaltyRate);
    }

    function addNewLoan(Loan memory _loan) private {
        loansById[_loan.loanId] = _loan;
        borrowerLoans[_loan.borrower.borrowerAddress].push(_loan.loanId);
    }

   
    // Borrower functions

    function requestLoan(uint256 _amount, LoanDuration _duration) external {
        require(_amount > 0, "The loan amount must be greater than zero");

        (, uint256 pendingLoansCount) = getPendingLoansArray();
        require(pendingLoansCount <= 500, "Loan limit reached, please wait for a loan to close.");

        uint256[] memory loans = borrowerLoans[msg.sender];
        for (uint i = 0; i < loans.length; i++) {
            uint256 loanId = loans[i];
            Loan memory userLoan = loansById[loanId];
            require(userLoan.status == LoanStatus.Paid, "You cannot request a new loan if you have pending, active, or overdue loans.");
        }

        loanCounter++;
        
        uint256 numberOfLoans = borrowerLoans[msg.sender].length;
        uint8 borrowerCreditScore = (numberOfLoans == 0) ? 1 : loanBorrowers[msg.sender].creditScore;

        (uint256 annualizedInterestRate, uint256 annualizedPenaltyRate) = loanInterestRateCalculator(borrowerCreditScore);

        Loan memory newLoan = Loan({
            loanId: loanCounter,
            borrower: LoanBorrower(msg.sender, borrowerCreditScore, borrowerLoans[msg.sender]), 
            lender: address(0),
            amount: _amount,
            interestRate: annualizedInterestRate,
            penaltyRate: annualizedPenaltyRate,
            startDate: 0,
            dueDate: 0,
            status: LoanStatus.Pending,
            duration: _duration
        });

        addNewLoan(newLoan);

        emit LoanRequested(loanCounter, msg.sender, _amount, LoanStatus.Pending, annualizedInterestRate, _duration);
    }

    function cancelLoan(uint256 _loanId) external payable {
        Loan storage loan = loansById[_loanId];
        address borrower = loan.borrower.borrowerAddress;
        uint256 cancelDeadline = loan.startDate + 1 days;

        require(borrower == msg.sender, "Only the borrower can cancel this loan");
        
        LoanStatus previousStatus = loan.status;
        
        if (loan.status == LoanStatus.Pending) {
            loan.status = LoanStatus.Canceled;
        } else if (loan.status == LoanStatus.Paid && loan.startDate < cancelDeadline) {
            require( loan.amount == msg.value,"");
            loan.status = LoanStatus.Canceled;
            payable(loan.lender).transfer(msg.value);
        } else {
            revert("No loan to cancel.");
        }

        emit LoanCanceled(_loanId, borrower, loan.amount, previousStatus);
    }

    function repayLoan(uint256 _loanId) external payable{
        Loan storage loan = loansById[_loanId];

        require(msg.sender == loan.borrower.borrowerAddress, "Only the borrower can repay his loan");
        require(loan.status == LoanStatus.Active || loan.status == LoanStatus.Overdue, "There is no loan to repay");
        require(msg.value == loan.amount, "");





        
    }

   
    // Lender functions

    function getPendingLoanDetailsByAmount() public view returns (Loan[] memory) {
        (Loan[] memory pendingLoans, uint256 pendingLoanCount) = getPendingLoansArray();

        for (uint256 i = 0; i < pendingLoanCount; i++) {
            for (uint256 j = 0; j < pendingLoanCount - 1 - i; j++) {
                if (pendingLoans[j].amount > pendingLoans[j + 1].amount) {
                    Loan memory temp = pendingLoans[j];
                    pendingLoans[j] = pendingLoans[j + 1];
                    pendingLoans[j + 1] = temp;
                }
            }
        }
        return pendingLoans;
    }

    function getPendingLoanDetailsByInterestRate() public view returns (Loan[] memory) {
        (Loan[] memory pendingLoans, uint256 pendingLoanCount) = getPendingLoansArray();

        for (uint256 i = 0; i < pendingLoanCount; i++) {
            for (uint256 j = 0; j < pendingLoanCount - 1 - i; j++) {
                if (pendingLoans[j].interestRate > pendingLoans[j + 1].interestRate) {
                    Loan memory temp = pendingLoans[j];
                    pendingLoans[j] = pendingLoans[j + 1];
                    pendingLoans[j + 1] = temp;
                }
            }
        }
        return pendingLoans;
    }

    function getPendingLoanByDuration(LoanDuration _duration) public view returns (Loan[] memory){
        (Loan[] memory pendingLoans, uint256 pendingLoanCount) = getPendingLoansArray();
        uint256 matchingLoanCount = 0;
        for (uint256 i = 0; i < pendingLoanCount; i++) {
            if (pendingLoans[i].duration == _duration) {
               matchingLoanCount++;
            }
        }

        Loan[] memory matchingLoans = new Loan[](matchingLoanCount);
        uint256 index = 0;

        for(uint256 i = 0; i < pendingLoanCount; i++){
            if(pendingLoans[i].duration == _duration){
                matchingLoans[index] = pendingLoans[i];
                index++;
            }   
        }
        return matchingLoans;
    }

    function getLoanFunds(uint256 _loanId) external payable {
        Loan storage loan = loansById[_loanId];
        address borrower = loan.borrower.borrowerAddress;
        uint loanDurationDays;

        require(loan.loanId == _loanId, "Loan not found");
        require(loan.status == LoanStatus.Pending, "This loan doesn't need funding");
        require(msg.value == loan.amount, "The amount sent does not match the requested loan amount");
        require(borrower != msg.sender, "Lender and borrower cannot be the same");

        if(loan.duration == LoanDuration.Month){
            loanDurationDays = 30;
        } else if (loan.duration == LoanDuration.SixMonths){
            loanDurationDays = 90;
        } else if (loan.duration == LoanDuration.Year){
            loanDurationDays = 365;
        }

        loan.lender = msg.sender;
        loan.startDate = block.timestamp;
        loan.dueDate = block.timestamp + (loanDurationDays * 1 days);
        loan.status = LoanStatus.Active;

        payable(borrower).transfer(msg.value);

        emit LoanFunded(loan.loanId, msg.sender, borrower, msg.value, loan.startDate, loan.dueDate);
    }
}
