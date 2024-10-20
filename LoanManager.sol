
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import "./LoanLibrary.sol";

contract LoanManager{

    //variables and structs
    enum LoanStatus{
        Active,
        Pending,
        Paid,
        Overdue,
        Canceled
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
    mapping(address => LoanBorrower) public loanBorrowers; //create an index tp track every borrower with his history of loans
    mapping(address => uint256[]) public userLoans; //update the borrower struct with all his loan.

    //events
    event LoanRequested(uint256 loanId, address indexed borrower, uint256 indexed amount, LoanStatus status, uint256 indexed interestRate );
    event LoanFunded(uint256 loanId, address lender, address borrower, uint256 amount, uint256 startDate, uint256 dueDate);

    //functions

    //private and internal functions

    function getPendingLoansArray() private view returns (Loan[] memory,uint256) {
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

    function loanInterestCalculator(uint8 _borrowerCreditScore) private pure returns (uint256, uint256) {
        require(_borrowerCreditScore >= 0, "Invalid credit score");
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

    function addNewLoan(Loan memory _loan) private {
        loansById[_loan.loanId] = _loan;
        userLoans[_loan.borrowerAddress.borrowerAddress].push(_loan.loanId);   
    }

    function cancelPendingLoan(Loan storage loan) private {
        loan.status = LoanStatus.Canceled; 
    }



    //borrower functions
    
    function requestLoan(uint256 _amount) external {
        //requires
        require(_amount > 0, "The loan amount must be greater than zero");
        (, uint256 pendingLoansCount) = getPendingLoansArray();
        require(pendingLoansCount <= 500, "Loan limit reached, please wait for one to be closed to free up a slot.");
        uint256[] memory loans = userLoans[msg.sender];

        for (uint i = 0; i < loans.length; i++) {
            uint256 loanId = loans[i];
            Loan memory userLoan = loansById[loanId];

        require(userLoan.status == LoanStatus.Paid, "You cannot request a new loan if you have pending, active, or overdue loans");
        }
        
        loanCounter++;
        if (loanBorrowers[msg.sender].borrowerAddress == address(0)) {
            loanBorrowers;
        }
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

    function cancelLoan(uint256 _loanId) external payable {
        Loan storage loan = loansById[_loanId];
        address BorrowerAddress = loan.borrowerAddress.borrowerAddress;
        uint cancelDueDate = loan.startDate + 1 days;

        require(BorrowerAddress == msg.sender, "Only the borrower can cancel this loan");
        if(loan.status == LoanStatus.Pending){
            cancelPendingLoan(loan);
        } else if(loan.status == LoanStatus.Paid && loan.startDate < cancelDueDate){

        } else {
            revert("This address has no loan to cancel");
        }
    }

    //lender functions

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

    function getLoanFunds(uint256 _loanId) external payable  {
        Loan storage loan = loansById[_loanId];
        address BorrowerAddress = loan.borrowerAddress.borrowerAddress;

        require(loan.loanId == _loanId, "Loan not found");
        require(loan.status == LoanStatus.Pending, "This loan doesn't need funds");
        require(msg.value == loan.amount, "The amount sent does not match the amount requested by the borrower");
        require(BorrowerAddress != msg.sender, "Lender and borrower cannot be the same.");  

        loan.lenderAddress = msg.sender;
        loan.amount = msg.value;
        loan.startDate = block.timestamp;
        loan.dueDate = block.timestamp + (daysOfLoan * 1 days) ;
        loan.status = LoanStatus.Active;

         payable(BorrowerAddress).transfer(msg.value);

        emit LoanFunded(loan.loanId, msg.sender, BorrowerAddress, msg.value, loan.startDate, loan.dueDate);
        
    }




}