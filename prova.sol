// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Progettointroblockchain {
    //Variables
         //total donation balance 
         uint256 public totalDonations = 0;
         //manager' s address
         address private managerAddress;
         //donation target
         uint256 public donationTarget;
         //amount of donators
         uint256 public totalDonors = 0;
         //donation ending
         bool public moneyTargetReached;
    
    //event
         event DonationReceived(address indexed donor, uint256 amount);
         event Withdrawal(address indexed manager, uint256 amount);
         event FundraisingClosed(bool success, uint256 totalAmount);
        
        //make manager unique
        modifier onlyOwner() {
        require(msg.sender == managerAddress, "Not authorized");
        _;
        }

        // Mapping addresses and donations
        mapping(address => uint256) public donations;

    
    //Functions
        //default data
        constructor (uint256 _donationTarget) {
           donationTarget = _donationTarget;
           moneyTargetReached = false; 
           managerAddress = msg.sender;
        }

        //Ether donation permission
        function donate()public payable {
            //check conditions to donate
             require(msg.value > 0, "Donation must be greater than 0");
             require(moneyTargetReached == false, "Fundrising is closed");
             //Update donors counter
             if(donations[msg.sender] == 0){             
             totalDonors = totalDonors+1;
             }
            donations[msg.sender] += msg.value;
            totalDonations += msg.value;
            emit DonationReceived(msg.sender, msg.value); 
        } 
        
        //Ether withdraw permission
        function withdraw(uint256 amount) external onlyOwner {   
             require(amount <= address(this).balance, "Insufficient funds");
             require(moneyTargetReached == true, "Fundraising is not closed yet");
             payable(msg.sender).transfer(amount);
             emit Withdrawal(msg.sender, amount);
        } 

        //Close fundraising
        function closeFundraising() external onlyOwner{
            require(moneyTargetReached == false, "Fundraising is already closed");
            moneyTargetReached = true; 
            emit FundraisingClosed(false, totalDonations);
        }

        //Checking target 
        function checkTarget() public view returns (bool) {
             return totalDonations >= donationTarget;
        }

        //Target status update
        function updateTargetStatus() public {
             if (totalDonations >= donationTarget) {
             moneyTargetReached = true;
             }
        }      
}




