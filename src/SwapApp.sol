// SPDX-License-Identifier: MIT

pragma solidity "0.8.29";

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUniswapV3.sol";


contract SwapApp is Ownable{
  using SafeERC20 for IERC20;

  // --- Custom Errors ---
    error ZeroAddress();
    error InvalidPath();
    error DeadlineExceeded();
    error InsufficientBalance();
    error FeeTooHigh(uint256 fee);

    // --- State Variables ---
    address public immutable v3Router;
    uint256 public feeBps = 30; // 0.3% base fee

     // --- Events ---
    event SwapExecuted(
        address indexed user, 
        address indexed tokenIn, 
        address indexed tokenOut, 
        uint256 amountIn, 
        uint256 amountOut, 
        uint256 protocolFee
    );    
    event FeesWithdrawn(address indexed token, uint256 amount);
    event FeeUpdated(uint256 newFeeBps);

constructor( address _v3Router, address _admin) Ownable(_admin){
  if(_v3Router == address(0) || _admin == address(0)) revert ZeroAddress();
   v3Router = _v3Router;
 }

 function swapTokens(address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        uint24 _poolFee,
        uint256 _deadline) external returns (uint256 amountOut) {

        if(block.timestamp > _deadline) revert DeadlineExceeded();

   IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);

   //Calculate 0.3% fee
   uint256 protocolFee = (_amountIn * feeBps) /10000;
   uint256 amountToSwap = _amountIn - protocolFee;

   IERC20(_tokenIn).forceApprove(v3Router, amountToSwap);

   // 4. Ejecución: Configuración de parámetros para Uniswap V3
        IUniswapV3.ExactInputSingleParams memory params = IUniswapV3.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: _poolFee,
            recipient: msg.sender, // El router envía los tokens directo al usuario
            deadline: _deadline,
            amountIn: amountToSwap,
            amountOutMinimum: _amountOutMin,
            sqrtPriceLimitX96: 0
        });

  amountOut = IUniswapV3(v3Router).exactInputSingle(params);

   emit SwapExecuted(msg.sender, _tokenIn, _tokenOut, _amountIn, amountOut, protocolFee);
 }

 function setFee(uint256 _newFeeBps) external onlyOwner {
  if(_newFeeBps > 500) revert FeeTooHigh(_newFeeBps);
  feeBps = _newFeeBps;
  emit FeeUpdated(_newFeeBps);
}

//@notice Retira las comisiones acumuladas en el contrato.

function withdrawFees(address _token) external onlyOwner {
  uint256 balance = IERC20(_token).balanceOf(address(this));
  if(balance == 0) revert InsufficientBalance();

  IERC20(_token).safeTransfer(owner(), balance);
  emit FeesWithdrawn(_token, balance);
}
}

