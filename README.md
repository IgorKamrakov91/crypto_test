# Crypto Test

A small Ethereum balance checker with a Ruby/Sinatra API and a Vue/Vite frontend.

The backend validates an Ethereum wallet address, queries an Ethereum JSON-RPC endpoint, and returns the balance in ETH. The frontend provides a simple form for selecting an RPC provider and checking a wallet balance from the browser.

## Features

- Sinatra API endpoint for ETH balance lookups.
- Ethereum address validation through the `eth` Ruby gem.
- Wei-to-ETH conversion using `BigDecimal` for precision.
- Vue 3 frontend powered by Vite with preset and custom RPC provider support.
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

The app defaults to `https://eth.llamarpc.com`, can read a backend default from `ETH_RPC_URL`, and the UI also includes Cloudflare and Ankr options.

## Backend setup

Copy the example environment file before starting local services:

```bash
cp .env.example .env
```

The checked-in example uses public development defaults. Keep any private RPC
provider URLs or API keys in your local `.env` file only.

Optional environment variables:

| Variable | Purpose | Default |
| --- | --- | --- |
| `ETH_RPC_URL` | Backend fallback RPC provider when the request omits `rpc_url`. | `https://eth.llamarpc.com` |
| `CORS_ORIGINS` | Comma-separated browser origins allowed to call the API. | `http://localhost:5173` |

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

Set `VITE_API_BASE_URL` when the Sinatra API is not running at the default
`http://localhost:4567`:

```bash
VITE_API_BASE_URL=http://localhost:4567 npm run dev
```

## API usage

Check that the API is running without calling an RPC provider:

```bash
curl "http://localhost:4567/health"
```

Fetch a wallet balance:

```bash
curl "http://localhost:4567/balance/0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
```

Use a custom RPC endpoint with the `rpc_url` query parameter:

```bash
curl "http://localhost:4567/balance/0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045?rpc_url=https%3A%2F%2Fcloudflare-eth.com"
```

Custom RPC URLs must be HTTP(S) URLs with a host, must not include embedded
credentials, and must not target localhost, private, reserved, multicast, or
ambiguous encoded IP addresses. Keep provider-specific API keys in local
environment files instead of passing them through browser-visible URLs.

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

Build the frontend production bundle:

```bash
cd frontend
npm run build
```

## Development notes

- The frontend defaults to `http://localhost:4567`; set `VITE_API_BASE_URL`
  when the API is served from a different origin or port.
- CORS defaults to the Vite development server at `http://localhost:5173`; set `CORS_ORIGINS` to a comma-separated list when additional frontend origins should call the API.
- Set `ETH_RPC_URL` when you want the backend to use a different default RPC provider.
- Do not commit private RPC credentials or provider API keys. Use local environment files for secrets.
