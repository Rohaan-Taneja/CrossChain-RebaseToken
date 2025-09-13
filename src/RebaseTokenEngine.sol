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

interface Interface_RebaseToken {
    function mint(address to, uint256 amount) external returns (bool);
    function burn(uint256 amount, address from) external returns (bool);
}

contract RebaseTokenEngine {
    // errors

    error Error_occuredInDepositingTokens();

    error Error_occuredInBuringTokens();

    // type declaration

    RebaseToken rebaseToken;

    // state variables

    mapping(address => uint256) private userDeposited_ETH_Balance;

    address private immutable i_rebaseToken;

    // Events

    event EtheriumDepositedToContract(address from , uint256 amount);

    event EtheriumRedeemedFromTheContract(address to , uint256 amount);

    // modifiers

    modifier AmountGreaterThanZero(uint256 _amount) {
        require(_amount > 0, "Amount should be greater that zero");
        _;
    }

    constructor(address rebaseTokenAddress) {
        i_rebaseToken = rebaseTokenAddress;
    }

    // recieve function
    /**
     * @notice => this will take eth tokens and give equivalent rebase token
     */
    function Deposit_and_mint() external payable AmountGreaterThanZero(msg.value) {
        userDeposited_ETH_Balance[msg.sender] += msg.value;
        // minting equivalent amount of new rebase token to user
        (bool success) = Interface_RebaseToken(i_rebaseToken).mint(msg.sender, msg.value);

        if (!success) {
            revert Error_occuredInDepositingTokens();
        }

        emit EtheriumDepositedToContract(msg.sender, msg.value);
    }

    /**
    @notice => In this function user will tell how much he wants to withraw,
    @notice => that much rebase token will be burnt
    @notice => and equivalent amount of eth tokens are sent back to the user
     */
    function burn_and_withdraw(uint256 _amount) external AmountGreaterThanZero(_amount) {
      
        (bool success) = Interface_RebaseToken(i_rebaseToken).burn(_amount, msg.sender);

        if (!success) {
            revert Error_occuredInBuringTokens();
        }

        userDeposited_ETH_Balance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);

        emit EtheriumRedeemedFromTheContract(msg.sender, _amount);
    }

    // fallback
    // function to send eth to the contratc for rewards
    receive() external payable {}

    // external function

    // internal Function

    //  private functions

    // view function

    function getUser_ETH_Balance(address _user) public view returns (uint256) {
        return userDeposited_ETH_Balance[_user];
    }
}
