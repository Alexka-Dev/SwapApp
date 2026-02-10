# SwapApp

This is a token swapping application that allows users to exchange tokens in a liquidity pool.

## 🛠 Technical Features

- **Swap Single:** Execution of single-hop swaps (Exact Input Single).
- **Protocol Fees:** Integrated adjustable fee collection system (configurable in basis points - BPS).
- **Security:** Implementation of `SafeERC20` for secure transfers and `Ownable` for administrative management.
- **Optimization:** Use of `Custom Errors` for gas savings and `Immutable variables` for protocol addresses.
- **Arbitrum Focus:** Configured and tested for the most liquid assets: **WETH, USDC, and DAI**.

### 📋 Prerequisites

Before starting, ensure you have installed:

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (Forge, Cast, Anvil).
- An RPC URL for Arbitrum (you can use Alchemy, Infura, or a public node).

## 🚀 Installation & Setup

Follow these steps to set up the project locally:

1. **Clone the repository:**

   ```bash
   git clone [https://github.com/Alexka-Dev/SwapApp.git](https://github.com/Alexka-Dev/SwapApp.git)
   cd SwapApp

   ```

2. **Install dependencies:**
   Foundry uses Git submodules for libraries. Run the following command to download OpenZeppelin and Forge-std:

   ```bash
   forge install

   ```

3. **Compile the project:**
   ```bash
   forge build
   ```

## 🧪 Running Tests

Since the contract interacts with the real Uniswap V3 protocol, tests must be executed using a Mainnet Fork of Arbitrum One. This allows for simulating real network state and current liquidity.

Run all tests using the following command:

```bash
forge test --fork-url [selected-arbitrum-network] --match-test [test-name]
```

### 🧪 Key Tests Included:

1. **testDeployedCorrectly:** Verifies that the Router and Admin are correctly assigned.
2. **testSwapWethToUsdc:** Validates swaps between assets with different decimals.
3. **testSwapUsdcToDai:** Validates stablecoin swaps using low-fee pools.
4. **testProtocolFeeCollection:** Ensures the contract correctly retains fees and that the admin can withdraw them.

### 📍 Reference Addresses (Arbitrum One)

- Uniswap V3 Router,0xE592427A0AEce92De3Edee1F18E0157C05861564
- WETH,0x82aF49447D8a07e3bd95BD0d56f35241523fBab1
- USDC,0xaf88d065e77c8cC2239327C5EDb3A432268e5831
- DAI,0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1

_Developed_ by **Alexka-Dev**
