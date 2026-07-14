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
