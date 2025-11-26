This project provides a crypto service for fetching cryptocurrency balances.

## CryptoBalanceFetcher

The `CryptoBalanceFetcher` class is responsible for retrieving the Ethereum (ETH) balance for a given wallet address.

### Features:
- Connects to an Ethereum RPC node (defaults to `https://eth.llamarpc.com`).
- Validates the provided Ethereum wallet address.
- Fetches the balance in Wei and converts it to Ether using `BigDecimal` for precision.
