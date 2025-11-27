<script setup>
import { ref } from 'vue'

const address = ref('')
const balance = ref(null)
const error = ref(null)
const loading = ref(false)
const rpcUrl = ref('https://eth.llamarpc.com')

const rpcOptions = [
  { name: 'LlamaRPC', url: 'https://eth.llamarpc.com' },
  { name: 'Cloudflare', url: 'https://cloudflare-eth.com' },
  { name: 'Ankr', url: 'https://rpc.ankr.com/eth' }
]

const exampleAddress = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'

const fillExample = () => {
  address.value = exampleAddress
}

const fetchBalance = async () => {
  if (!address.value) return

  loading.value = true
  error.value = null
  balance.value = null

  try {
    const encodedRpc = encodeURIComponent(rpcUrl.value)
    const response = await fetch(`http://localhost:4567/balance/${address.value}?rpc_url=${encodedRpc}`)
    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.error || 'Failed to fetch balance')
    }

    balance.value = data.balance_eth
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="card">
    <h2>Check ETH Balance</h2>
    
    <div class="settings-group">
      <label>
        RPC Node:
        <select v-model="rpcUrl">
          <option v-for="opt in rpcOptions" :key="opt.url" :value="opt.url">
            {{ opt.name }}
          </option>
        </select>
      </label>
    </div>

    <div class="input-group">
      <input 
        v-model="address" 
        placeholder="Enter ETH Address" 
        @keyup.enter="fetchBalance"
        class="address-input"
      />
      <button @click="fetchBalance" :disabled="loading">
        {{ loading ? 'Checking...' : 'Check Balance' }}
      </button>
    </div>
    
    <div class="example-link">
      <a href="#" @click.prevent="fillExample">Use Example Address</a>
    </div>

    <div v-if="error" class="error">
      {{ error }}
    </div>

    <div v-if="balance !== null" class="result">
      Balance: <strong>{{ balance }} ETH</strong>
    </div>
  </div>
</template>

<style scoped>
.card {
  padding: 2em;
  text-align: center;
  max-width: 500px;
  margin: 0 auto;
}

.settings-group {
  margin-bottom: 1em;
}

.settings-group select {
  padding: 0.4em;
  border-radius: 4px;
  border: 1px solid #ccc;
  margin-left: 0.5em;
}

.input-group {
  margin: 1em 0;
  display: flex;
  gap: 10px;
  justify-content: center;
  flex-wrap: wrap;
}

.address-input {
  padding: 0.6em 1.2em;
  font-size: 1em;
  width: 300px;
  border-radius: 8px;
  border: 1px solid #ccc;
}

button {
  border-radius: 8px;
  border: 1px solid transparent;
  padding: 0.6em 1.2em;
  font-size: 1em;
  font-weight: 500;
  font-family: inherit;
  background-color: #1a1a1a;
  color: white;
  cursor: pointer;
  transition: border-color 0.25s;
}

button:hover {
  border-color: #646cff;
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.7;
}

.example-link {
  font-size: 0.9em;
  margin-top: -0.5em;
  margin-bottom: 1em;
}

.example-link a {
  color: #646cff;
  text-decoration: none;
}

.example-link a:hover {
  text-decoration: underline;
}

.error {
  color: #ff4646;
  margin-top: 1em;
}

.result {
  margin-top: 1em;
  font-size: 1.2em;
}
</style>
