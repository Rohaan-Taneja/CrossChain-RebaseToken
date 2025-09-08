// SPDX-License-Identifier: MIT


// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// constructor
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RebaseToken is ERC20, Ownable(address(msg.sender)) {

    //errors

    error InterestRatesWillDecreaseWithTime(uint256 InterestRate, uint256 OldInterestRate);


    // type declaration



    // State variables


    // interestRate per year in 1e18 precision
    // since this interestis scaled up ( should be 0.05 , but it is 0.05 + 1e18 )
    // so whenever we use it , we need to divide the answer by 1e18 , to get the actual answer
    uint256 private globalInterestRatePerYear = 5e16; //scaled to 1e18 precision
    uint256 SECONDS_PER_YEAR = 31536000;
    uint256 ratePerSecond = globalInterestRatePerYear / SECONDS_PER_YEAR;

    // before updating balance , we will store totol interest gained on previos principle amount
    // if amount zero , then first time depositor , so that will be zero , if not then it interest on previous amount will be stored here 
    mapping (address => uint256) private InterestGained_beforeUpdatingBalance;

    mapping (address => uint256) internal userToken_LastUpdatedTime;



    // Events

    event globalInterestRateupdated(uint256 _newInterestRate);




    constructor(string memory _tokenName, string memory _symbol) ERC20(_tokenName, _symbol) {}

    function mint(address _user, uint256 amount) external onlyOwner returns(bool){
        _mint(_user, amount);
        userToken_LastUpdatedTime[_user] = block.timestamp;

        return true;

        
    }

    function burn(uint256 amount, address user) external  onlyOwner{
        _burn(user, amount);
    }



        /**
     * @notice => this function will be called only owner to update the interest of the contract
     * @param _newInterestRatePerYear = > this is the new interest rate( in 1e18 precision) that onwer can set and can only be lesser that the previous interest rate
     */
    function UpdateInterestRate(uint256 _newInterestRatePerYear) external onlyOwner {
        if (_newInterestRatePerYear > globalInterestRatePerYear) {
            revert InterestRatesWillDecreaseWithTime(_newInterestRatePerYear, globalInterestRatePerYear);
        }
        globalInterestRatePerYear = _newInterestRatePerYear;
        emit globalInterestRateupdated(_newInterestRatePerYear);
    }


    function balanceOf(address _user) public view override returns(uint256){

        return super.balanceOf(_user) + get_InterestGained_beforeUpdatingBalance(_user) +  interestGained_on_currentAmount_sinceLastUpdatedTime(_user) ;

    }


    /**
    @notice => this function returning total interest earned by the user since last principle and time is updated
    @notice => maybe user has added more amount , so time is update to that time , so total interest on that total amount for (current_time - that_update_time)
    @param _user => the user whos interest is being calculated
     */
    function interestGained_on_currentAmount_sinceLastUpdatedTime(address _user) public view  returns(uint256){

        return (super.balanceOf(_user)*ratePerSecond*userToken_LastUpdatedTime[_user])/1e18;

    }

    /**
    @notice => total interest gained on total principle amount before updating the balance & time
    @notice => idea is , if user add more principle/amount , then we will store interest gained for the current amount/before_updating_the_amount and time_deposited
    @notice => since this is updating the user interest gained state , it can be called multiple times and can be hacked , so making it onlyowner and it will called only when the user deposit eth
    @param _user => this is the user who is adding more amount , so we are storing its interest gained till now on current deposited amount , before updaing total amount and last_updated_time
     */
    function InterestGained_beforeUpdatingTokenBalance(address _user) external onlyOwner() {
        InterestGained_beforeUpdatingBalance[_user] += (super.balanceOf(_user)*ratePerSecond*userToken_LastUpdatedTime[_user])/1e18;

    }


    
    



    // view 

    function get_InterestGained_beforeUpdatingBalance(address _user) public view returns(uint256){
        return InterestGained_beforeUpdatingBalance[_user] ;
    }

    function get_userTokenLastUpdateTime(address _user) view public returns(uint256){
        return userToken_LastUpdatedTime[_user];
    }
}
