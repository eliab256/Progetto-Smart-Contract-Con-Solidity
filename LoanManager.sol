// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract LoanManager {

    // Enum to represent loan statuses
    enum LoanStatus {
        Active,
        Pending,
        Paid,
        Overdue,
        Canceled
    }

    // Struct to represent a borrower and their loans
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
    }

    uint256 private loanCounter;
    uint16 private constant loanDurationDays = 365;

    // Mappings to track loans and borrowers
    mapping(uint256 => Loan) public loansById;  // Tracks each loan by its ID
    mapping(address => LoanBorrower) public loanBorrowers; // Tracks each borrower with their loan history
    mapping(address => uint256[]) public borrowerLoans; // Tracks loans by borrower address

    // Events
    event LoanRequested(uint256 loanId, address indexed borrower, uint256 indexed amount, LoanStatus status, uint256 indexed interestRate);
    event LoanFunded(uint256 loanId, address lender, address borrower, uint256 amount, uint256 startDate, uint256 dueDate);

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

    function loanInterestCalculator(uint8 _creditScore) private pure returns (uint256, uint256) {
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

    function cancelPendingLoan(Loan storage loan) private {
        loan.status = LoanStatus.Canceled;
    }
    function cancelActiveLoan(Loan storage loan) private {

    }

    // Borrower functions

    function requestLoan(uint256 _amount) external {
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

        (uint256 annualizedInterestRate, uint256 annualizedPenaltyRate) = loanInterestCalculator(borrowerCreditScore);

        Loan memory newLoan = Loan({
            loanId: loanCounter,
            borrower: LoanBorrower(msg.sender, borrowerCreditScore, borrowerLoans[msg.sender]), 
            lender: address(0),
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

    function cancelLoan(uint256 _loanId) external payable {
        Loan storage loan = loansById[_loanId];
        address borrower = loan.borrower.borrowerAddress;
        uint256 cancelDeadline = loan.startDate + 1 days;

        require(borrower == msg.sender, "Only the borrower can cancel this loan");
        
        if (loan.status == LoanStatus.Pending) {
            cancelPendingLoan(loan);
        } else if (loan.status == LoanStatus.Paid && loan.startDate < cancelDeadline) {
            cancelActiveLoan(loan); //completare con il payble e il rimborso al proprietario
        } else {
            revert("No loan to cancel.");
        }
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

    function getLoanFunds(uint256 _loanId) external payable {
        Loan storage loan = loansById[_loanId];
        address borrower = loan.borrower.borrowerAddress;

        require(loan.loanId == _loanId, "Loan not found");
        require(loan.status == LoanStatus.Pending, "This loan doesn't need funding");
        require(msg.value == loan.amount, "The amount sent does not match the requested loan amount");
        require(borrower != msg.sender, "Lender and borrower cannot be the same");

        loan.lender = msg.sender;
        loan.startDate = block.timestamp;
        loan.dueDate = block.timestamp + (loanDurationDays * 1 days);
        loan.status = LoanStatus.Active;

        payable(borrower).transfer(msg.value);

        emit LoanFunded(loan.loanId, msg.sender, borrower, msg.value, loan.startDate, loan.dueDate);
    }
}
