// SPDX-License-Identifier: MIT

pragma solidity "0.8.29";

import { Test, console } from "forge-std/Test.sol";
import { SwapApp } from "../src/SwapApp.sol";
import { IERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SwapTest is Test {

SwapApp app;
// Direcciones Arbitrum One
    address constant V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant DAI  = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    address user = makeAddr("User");
    address admin = makeAddr("Admin");

function setUp() public {
   app = new SwapApp(V3_ROUTER, admin);

}

function testDeployedCorrectly() public view {
   assertEq(app.v3Router(), V3_ROUTER);
   assertEq(app.owner(), admin);
}

// --- PRUEBA 1: WETH a USDC (Volátil a Stable 6 decimales) ---
    function testSwapWethToUsdc() public {
        uint256 amountIn = 1 ether; // 1 WETH (18 dec)
        uint24 poolFee = 500;       // Pool de 0.05% (común para WETH/USDC)
        
        deal(WETH, user, amountIn);

        vm.startPrank(user);
        IERC20(WETH).approve(address(app), amountIn);
        
        uint256 amountOut = app.swapTokens(WETH, USDC, amountIn, 0, poolFee, block.timestamp + 60);
        
        assertTrue(amountOut > 0, "No se recibio USDC");
        console.log("USDC recibido por 1 WETH:", amountOut / 1e6); 
        vm.stopPrank();
    }

    // --- PRUEBA 2: USDC a DAI (Stable 6 dec a Stable 18 dec) ---
    function testSwapUsdcToDai() public {
        uint256 amountIn = 1000 * 1e6; // 1000 USDC (6 dec)
        uint24 poolFee = 100;          // Pool de 0.01% (ideal para stables)
        
        deal(USDC, user, amountIn);

        vm.startPrank(user);
        IERC20(USDC).approve(address(app), amountIn);
        
        uint256 amountOut = app.swapTokens(USDC, DAI, amountIn, 0, poolFee, block.timestamp + 60);
        
        assertTrue(amountOut > 0, "No se recibio DAI");
        console.log("DAI recibido por 1000 USDC:", amountOut / 1e18);
        vm.stopPrank();
    }

    // --- PRUEBA 3: WETH a DAI (Volátil a Stable 18 decimales) ---
    function testSwapWethToDai() public {
        uint256 amountIn = 1 ether; 
        uint24 poolFee = 3000; // Pool de 0.3%
        
        deal(WETH, user, amountIn);

        vm.startPrank(user);
        IERC20(WETH).approve(address(app), amountIn);
        
        uint256 amountOut = app.swapTokens(WETH, DAI, amountIn, 0, poolFee, block.timestamp + 60);
        
        assertTrue(amountOut > 0, "No se recibio DAI");
        console.log("DAI recibido por 1 WETH:", amountOut / 1e18);
        vm.stopPrank();
    }

    // --- PRUEBA 4: Cobro de Comisiones con WETH ---
    function testFeeWithdrawalWithWeth() public {
        uint256 amountIn = 10 ether;
        deal(WETH, user, amountIn);

        vm.startPrank(user);
        IERC20(WETH).approve(address(app), amountIn);
        app.swapTokens(WETH, USDC, amountIn, 0, 500, block.timestamp + 60);
        vm.stopPrank();

        uint256 expectedFee = (amountIn * app.feeBps()) / 10000;
        
        vm.prank(admin);
        app.withdrawFees(WETH);

        assertEq(IERC20(WETH).balanceOf(admin), expectedFee, "Admin no recibio la comision");
    }

}

