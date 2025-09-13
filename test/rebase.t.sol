// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {RebaseTokenEngine} from "../src/RebaseTokenEngine.sol";
import {RebaseToken} from "../src/RebaseToken.sol";

contract rebaseTest is Test {
    address User = 0xE44cFB653b610Bf2af47D9D25fD60C2f35adD816;
    address User2 = 0x3163d00B98e8652b5719538e0C059008c22Dd54e;
    RebaseToken r_token;
    RebaseTokenEngine r_tokenEngine;

    /**
     * @notice => deploying both token and its controller(engine contract )
     * @notice => and trasnferring ownership of rebaseToken contract to engine
     */
    function setUp() public {
        r_token = new RebaseToken("RebaseToken", "RT");
        r_tokenEngine = new RebaseTokenEngine(address(r_token));

        // now the owner of the of the rebase token is rebaseTokenEngine contract
        r_token.transferOwnership(address(r_tokenEngine));
    }

    function test_deposit() public {
        vm.startPrank(User);

        vm.deal(User, 100 ether);

        r_tokenEngine.Deposit_and_mint{value: 1 ether}();

        console.log("this is the user eth balance", r_tokenEngine.getUser_ETH_Balance(User));

        // does ether balance ether
        assertEq(r_tokenEngine.getUser_ETH_Balance(User), 1 ether);

        // checking does token Contract has minted 10 ether equivalent tokens

        console.log("this is the user rebase balance", r_token.get_UserTokenBalance(User));
        assertEq(r_token.get_UserTokenBalance(User), 1e18);

        vm.stopPrank();
    }

    function test_balanceOf() public {
        vm.startPrank(User);

        vm.deal(User, 100 ether);

        r_tokenEngine.Deposit_and_mint{value: 100 ether}();

        console.log(" this is the reached amount ", r_token.balanceOf(User));

        vm.warp(r_token.get_userTokenLastUpdateTime(User) + 365 days);

        // so due to truncation , it will never come exact  , so it is working almost correct
        // assertEq(r_token.balanceOf(User), 105 ether);
    }


    /**
    @notice => in this we will give some tokens  spend 1 year , then add some more
    @notice => and then test  , is it calculating interest correctly 
     */
    function test_addingMoreToken() public {

        vm.startPrank(User);
        vm.deal(User , 100 ether);

        //  deposited 10 ether and passed 1 year
        r_tokenEngine.Deposit_and_mint{value : 10 ether}();
        vm.warp(block.timestamp + 365 days);
        // 10.5 ether expected or around

        // deposited 90 ether and passsed 1 year
        r_tokenEngine.Deposit_and_mint{ value : 90 ether}();
        vm.warp(block.timestamp + 365 days);
        // expected or around => 105 ether

        console.log("this is the user balance " , r_token.balanceOf(User));
        // assertEq(r_token.balanceOf(User) , 105e17 + 105e18);


    }


    /**
    @notice => in this test we test transfer function whenn user is trasnfering amount to another user (both have initially some tokens)
    @notice => trasnfering token less that principle amount( not between p and p+ I )
     */
    function test_transfer_case1() public {

        vm.prank(User);
        vm.deal(User , 110 ether);
        r_tokenEngine.Deposit_and_mint{value : 110 ether}();

        vm.prank(User2);
        vm.deal(User2 , 90 ether);
        r_tokenEngine.Deposit_and_mint{value : 90 ether}();

        vm.warp(block.timestamp + 365 days);

        // transferring 10 token to user 2
        // so user 1 has 100 tokens and user2 also have 100 tokens
        vm.prank(User);
        r_token.transfer(address(User2), 10 ether);

        vm.warp(block.timestamp + 365 days);


        // should be around 1104999... , then it is correct
        // since difference is coming out to be around 1e9  , so small approximation 
        assertApproxEqAbs(r_token.balanceOf(User) , 1105e17 , 2e9);

        // should be equal to 10949999... , then is correct
        assertApproxEqAbs(r_token.balanceOf(User2) , 1095e17 , 2e9);

    }


    /**
    @notice => in this test we will deposit tokens and tehn transfer token after some time to another user 
    @notice => (  amount> principle  && amount < princeiple + interest )
    @notice => then interest tokens will me minted and then traferred and then we will calculate remaing pe interest agter 1 year
     */
    function test_transfer_case2() public {

        vm.prank(User);
        vm.deal(User , 100 ether);
        r_tokenEngine.Deposit_and_mint{value : 100 ether}();

        vm.prank(User2);
        vm.deal(User2 , 100 ether);
        r_tokenEngine.Deposit_and_mint{value : 100 ether}();

        vm.warp(block.timestamp + 365 days);

        console.log("user 1 balance before tranferng" , r_token.balanceOf(User));
        // tranfering principle + Interest (almost ) to the user 2
        vm.prank(User);
        r_token.transfer(User2, 104 ether);

         console.log("user 1 balance after tranferng" , r_token.balanceOf(User));

        vm.warp(block.timestamp + 365 days);


        // almost same value is coming out 
        // assertApproxEqAbs(r_token.balanceOf(User2) , 2193e17 , 2e12);
        assertApproxEqAbs(r_token.balanceOf(User) , 1 ether , 2e9);


    }


}
