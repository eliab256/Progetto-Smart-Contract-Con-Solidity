// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LoanLibrary.sol";

contract LoanManager{
    using LoanLibrary for uint256;

    mapping(address => uint) public usersBalances ;

    enum LoanStatus{
        Active,
        Pending,
        Paid,
        Overdue
    }

    struct Loan{
        address borrowerAddress;
        address lenderAddress;
        uint256 amount;
        uint InterestRate; //in percentuale usando una scala di 100 es: 525 = 5,25%
        uint PenaltyRate;
        uint startDate; //usare timestamp 
        uint dueDate;
        bool isPaid;
        LoanStatus status;
    }



}



