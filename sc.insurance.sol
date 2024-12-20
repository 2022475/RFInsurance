// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TravelInsurance {
    address public insuranceCompany;
    address public airline;
    mapping(address => uint256) public insuredAmounts;
    mapping(address => bool) public claimsPaid;
    mapping(address => bool) public baggageClaimsProcessed;
    uint256 public airlinePenaltyBalance;
    uint256 public airlineRewardBalance;

    event PolicyPurchased(address indexed client, uint256 amount);
    event ClaimPaid(address indexed client, uint256 amount);
    event RefundProcessed(address indexed client, uint256 refundAmount);
    event AirlinePenalized(address indexed airline, uint256 penaltyAmount);
    event AirlineRewarded(address indexed airline, uint256 rewardAmount);
    event BaggageClaimProcessed(address indexed client, uint256 compensationAmount);
    event AssistanceProvided(address indexed client, string assistanceDetails);

    constructor(address _airline) {
        insuranceCompany = msg.sender; // The contract creator is the insurance company
        airline = _airline; // The associated airline
    }

    modifier onlyInsuranceCompany() {
        require(msg.sender == insuranceCompany, "Only the insurance company can perform this action");
        _;
    }

    modifier onlyAirline() {
        require(msg.sender == airline, "Only the airline can perform this action");
        _;
    }

    // Function to purchase an insurance policy
    function purchasePolicy() public payable {
        require(msg.value > 0, "Insurance amount must be greater than zero");
        require(insuredAmounts[msg.sender] == 0, "Policy already purchased");

        insuredAmounts[msg.sender] = msg.value;
        emit PolicyPurchased(msg.sender, msg.value);
    }

    // Function to process a claim if a flight delay is verified
    function processClaim(address client, bool flightDelayed) public onlyInsuranceCompany {
        require(insuredAmounts[client] > 0, "No policy found for this client");
        require(!claimsPaid[client], "Claim already paid");

        if (flightDelayed) {
            uint256 payout = insuredAmounts[client] / 2; // 50% payout for delays
            payable(client).transfer(payout);
            claimsPaid[client] = true;

            emit ClaimPaid(client, payout);
        }
    }

    // Function to issue a partial refund by the airline
    function processRefund(address client, uint256 refundAmount) public onlyAirline {
        require(insuredAmounts[client] > 0, "No policy found for this client");
        require(!claimsPaid[client], "Claim already paid");
        require(refundAmount <= insuredAmounts[client], "Refund amount exceeds insured amount");

        payable(client).transfer(refundAmount);
        emit RefundProcessed(client, refundAmount);
    }

    // Function to process a baggage loss claim
    function processBaggageClaim(address client, uint256 compensationAmount) public onlyInsuranceCompany {
        require(insuredAmounts[client] > 0, "No policy found for this client");
        require(!baggageClaimsProcessed[client], "Baggage claim already processed");

        payable(client).transfer(compensationAmount);
        baggageClaimsProcessed[client] = true;

        emit BaggageClaimProcessed(client, compensationAmount);
    }

    // Function to offer assistance for a missed flight
    function offerAssistanceForMissedFlight(address client, string memory assistanceDetails) public onlyInsuranceCompany {
        require(insuredAmounts[client] > 0, "No policy found for this client");
        require(!claimsPaid[client], "Claim already paid");

        emit AssistanceProvided(client, assistanceDetails);
    }

    // Function to penalize the airline for non-compliance
    function penalizeAirline(uint256 penaltyAmount) public onlyInsuranceCompany {
        airlinePenaltyBalance += penaltyAmount;
        emit AirlinePenalized(airline, penaltyAmount);
    }

    // Function to reward the airline for exemplary service
    function rewardAirline(uint256 rewardAmount) public onlyInsuranceCompany {
        require(address(this).balance >= rewardAmount, "Insufficient contract balance");
        airlineRewardBalance += rewardAmount;
        payable(airline).transfer(rewardAmount);

        emit AirlineRewarded(airline, rewardAmount);
    }

    // Function to deposit funds into the contract
    function depositFunds() public payable onlyInsuranceCompany {}

    // Function to withdraw funds from the contract by the insurance company
    function withdrawFunds(uint256 amount) public onlyInsuranceCompany {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(insuranceCompany).transfer(amount);
    }

    // Function to fetch details of a client's policy
    function getPolicyDetails() public view returns (uint256 insuredAmount, bool claimPaid, bool baggageClaimProcessed) {
        return (insuredAmounts[msg.sender], claimsPaid[msg.sender], baggageClaimsProcessed[msg.sender]);
    }

    // Function to get the penalty balance for the airline
    function getAirlinePenaltyBalance() public view returns (uint256) {
        return airlinePenaltyBalance;
    }

    // Function to get the reward balance for the airline
    function getAirlineRewardBalance() public view returns (uint256) {
        return airlineRewardBalance;
    }

    // Function to check the current balance of the contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}