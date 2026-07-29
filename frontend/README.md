# Crypto Test Frontend

Vue 3 + Vite client for checking ETH balances through the Sinatra backend.

## Setup

```bash
npm install
npm run dev
```

By default the client calls `http://localhost:4567`. To point it at another backend, create a local `.env` file in this directory and set:

```bash
VITE_API_BASE_URL=http://localhost:4567
```

Vite only exposes variables prefixed with `VITE_` to browser code.

When adding RPC provider URLs to the UI, use public HTTP(S) endpoints only. Do
not place provider API keys or credentials in frontend environment variables,
because Vite embeds `VITE_` values in the browser bundle. Custom RPC URLs are
also checked in the browser before submission and should not point at localhost
or private network hosts; the backend enforces the same SSRF guardrails.
