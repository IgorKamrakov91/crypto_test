# Crypto Test

A small Ethereum balance checker with a Ruby/Sinatra API and a Vue/Vite frontend.

The backend validates an Ethereum wallet address, queries an Ethereum JSON-RPC endpoint, and returns the balance in ETH. The frontend provides a simple form for selecting an RPC provider and checking a wallet balance from the browser.

## Features

- Sinatra API endpoint for ETH balance lookups.
- Ethereum address validation through the `eth` Ruby gem.
- Wei-to-ETH conversion using `BigDecimal` for precision.
- Vue 3 frontend powered by Vite.
- RSpec coverage for the balance-fetching service.

## Project structure

```text
.
├── app.rb                  # Sinatra API
├── crypto_service.rb       # Ethereum balance service
├── spec/                   # RSpec tests
└── frontend/               # Vue/Vite client
```

## Prerequisites

- Ruby with Bundler
- Node.js and npm
- Access to an Ethereum JSON-RPC endpoint

The app defaults to `https://eth.llamarpc.com`, and the UI also includes Cloudflare and Ankr options.

## Backend setup

Install Ruby dependencies:

```bash
bundle install
```

Start the Sinatra API:

```bash
ruby app.rb
```

By default Sinatra listens on `http://localhost:4567`.

## Frontend setup

Install frontend dependencies:

```bash
cd frontend
npm install
```

Start the Vite dev server:

```bash
npm run dev
```

Open the Vite URL shown in the terminal, usually `http://localhost:5173`.

## API usage

```bash
curl "http://localhost:4567/balance/0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
```

Use a custom RPC endpoint with the `rpc_url` query parameter:

```bash
curl "http://localhost:4567/balance/0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045?rpc_url=https%3A%2F%2Fcloudflare-eth.com"
```

Successful responses look like:

```json
{
  "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "balance_eth": "1.23"
}
```

## Running tests

```bash
bundle exec rspec
```

## Development notes

- The frontend currently calls `http://localhost:4567` directly.
- CORS is configured in `app.rb` for the Vite development server at `http://localhost:5173`.
- Do not commit private RPC credentials or provider API keys. Use local environment files for secrets.
