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

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {RebaseToken} from "./RebaseToken.sol";

contract RebaseTokenEngine {
    // errors

    error Error_occuredInDepositingTokens();

    // type declaration

    RebaseToken rebaseToken ;



    // state variables

    

    mapping (address => uint256)  private userDeposited_ETH_Balance ;

    

    

    // Events


    // modifiers
    modifier onlyOwner() {
        require(msg.sender == address(0x925d2885e8FD7cD701CaA78ab6450685f308F1ac) , "this is an only owner function , you cannot call it");
        _;
    }

    modifier AmountGreaterThanZero( uint256 _amount){
        require(_amount >0 , "Amount should be greater that zero");
        _;
    }

    constructor() {}

    // recieve function
    /**
     * @notice => this will take eth give rebase token
     */
    function Deposit() external payable AmountGreaterThanZero(msg.value){
        /**
        1)  calcultae interestGainer whether first time user or already present ()
        2) store that , that is total interest gained on current balance
        3) now update balance , add this princle depisted current time
        4) and n=mint new rebase tokens to the user
         */

        // calculating the interest gained on current principle amount + before updating amount and time
        // this is being called in the mint function 
        // rebaseToken.InterestGained_beforeUpdatingTokenBalance(msg.sender);
        userDeposited_ETH_Balance[msg.sender] += msg.value;
        // minting equivalent amount of new rebase token to user
        (bool success ) = rebaseToken.mint(msg.sender , msg.value);

        if(!success){
            revert Error_occuredInDepositingTokens();
        }

    }

    // fallback

    // external function

    






    // internal Function

    

    //  private functions


    // view function


    function getUser_ETH_Balance( address _user)  view public returns(uint256){
        return userDeposited_ETH_Balance[_user];

    }


}
