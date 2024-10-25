# Access to Credit: A Blockchain Solution for Low-Income Borrowers

This project involves a Solidity smart contract deployed on the Sepolia testnet, designed to provide 
loans to low-income individuals, enabling them to enhance their financial power.

## Index

    1. Description
    2. Contract Address on Sepolia
    3. Project Structure
    4. Clone and Configuration
    5. Technical Choices
    6. Contributing
    7. License
    8. Contacts


## 1. Description

This protocol aims to provide people with limited financial resources access to credit. 
Therefore, I could not use the classic collateralization system. The system is based on 
the credit scores of borrowers, which will increase if the loan is repaid within the agreed 
timeframe, providing more favorable rates. Conversely, if the loan is paid late, the credit 
score will degrade. The contract contains all the necessary functions for data visualization,
such as a list of all loans with their respective details, the ability for lenders to see all 
pending loans to be funded, the option to view these loans sorted by amount or interest rate, 
and the ability to check the status of an active loan. The practical functions allow borrowers 
to request a loan, cancel it within the first day of receiving funds, and repay the loan with 
interest. For lenders, in addition to the ability to view all loans, there is also the 
opportunity to provide liquidity to these loans.

## 2. Contract Address on Sepolia

0x00f9BC9517B77501408bF0e74a6CefF747e53860

## 3. Project structure

    The project is divided into two main files:

    1. **LoanManager.sol**: This file contains the main contract that handles all the logic about asking, taking and repaying loans.
    2. **NewsManagerLib.sol**: This file contains a support library used by the main contract to calculate interests and penalties.

## 4. Clone and Configuration

    1.  **Clone the repository**:

        ```bash
        git clone https://github.com/eliab256/Progetto-Smart-Contract-Con-Solidity.git
        ```
    2.  **Navigate into the project directory**:

        ```bash
        cd Progetto-Smart-Contract-Con-Solidity
        ```

## 5. Technical Choices

    Language
        -- **Solidity**: Solidity was chosen as it is the primary language for developing smart contracts on the Ethereum platform.

    Tools
         -- **Remix IDE**: Remix was used to write, test, and deploy the contract. It is an online development environment that offers a wide range of tools to facilitate the development process.

    Libraries
        -- **ReentracyGyard**: A library to prevent Reentrancy Attack, to import:  import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
        -- **LoanLibrary**: A library i made to calculate the amount of interest and penalty, to import import "./LoanLibrary.sol";

    Main Features
        Anyone can:
            - Search for loan details using the loan ID
            - Search for borrower details using a specific address
            - View the status of any loan at any time
           
        A potential borrower can:
            - Request a loan for any desired amount, to be repaid by a predetermined deadline (1 month, 6 months, 1 year)
            - Cancel the loan if it has not been filled, or within one day of receiving the funds by returning them to the lender
            - Repay the loan by the due date; if the deadline is missed, penalties apply, adding interest

        A potential lender can:
            - View pending loan requests sorted by amount
            - View pending loan requests sorted by interest rate
            - Filter pending loan requests by repayment deadline
            - Fund a loan request

## 6. Contributing 

    Thank you for your interest in contributing to the Environmental Quiz App! Every contribution is valuable and helps improve the project. There are various ways you can contribute:

    - Bug Fixes: If you find a bug, feel free to submit a fix.
    - Adding New Features: Propose new features or improvements.
    - Documentation: Help improve the documentation by writing guides or enhancing existing ones.
    - Fork: fork this project on other chains
    - Testing and Refactoring: Run tests on the code and suggest improvements. How to Submit a Contribution Fork the repository: Click the "Fork" button in the upper right corner to create a copy of the repository in your GitHub account.
    - Clone your fork: git clone https://github.com/eliab256/Progetto-Smart-Contract-Con-Solidity.git
    - Create a Branch: git checkout -b branch-name
    - Add and commit your change: git add . git commit -m "Modify description"
    - Send your branch to the fork: git push origin nome-branch
    - Create a pull request

    Final Tips
    - Clarity: Ensure that the instructions are clear and easy to follow.
    - Test the Process: If possible, test the contribution process from an external perspective to ensure it flows smoothly.
    - Keep It Updated: Update this section if the guidelines change or if the project evolves.

## 7. License

    This project is licensed under the MIT License.

## 8. Contacts

    For more information, you can contact me:

        - Project Link: https://github.com/eliab256/Progetto-Smart-Contract-Con-Solidity
        - Website: https://elia-bordoni-blockchain-dev.netlify.app/
        - Email: bordonielia96@gmail.com
        - Linkedin: https://www.linkedin.com/in/elia-bordoni/
