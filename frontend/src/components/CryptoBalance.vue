<script setup>
import { computed, ref } from 'vue'
import {
  hasValidEthereumAddressFormat,
  hasValidRpcUrlFormat,
  normalizeInput
} from '../lib/validation.js'

const address = ref('')
const balance = ref(null)
const error = ref(null)
const loading = ref(false)
const CUSTOM_RPC_VALUE = 'custom'

const rpcOptions = [
  { name: 'LlamaRPC', url: 'https://eth.llamarpc.com' },
  { name: 'Cloudflare', url: 'https://cloudflare-eth.com' },
  { name: 'Ankr', url: 'https://rpc.ankr.com/eth' }
]

const rpcUrl = ref(rpcOptions[0].url)
const customRpcUrl = ref('')

const apiBaseUrl = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:4567').replace(/\/$/, '')
const exampleAddress = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'
const normalizedAddress = computed(() => normalizeInput(address.value))
const isAddressFormatValid = computed(() => hasValidEthereumAddressFormat(normalizedAddress.value))
const isCustomRpcSelected = computed(() => rpcUrl.value === CUSTOM_RPC_VALUE)
const selectedRpcUrl = computed(() => (
  isCustomRpcSelected.value ? customRpcUrl.value : rpcUrl.value
))
const normalizedSelectedRpcUrl = computed(() => normalizeInput(selectedRpcUrl.value))
const isCustomRpcUrlValid = computed(() => (
  !isCustomRpcSelected.value || !normalizedSelectedRpcUrl.value || hasValidRpcUrlFormat(normalizedSelectedRpcUrl.value)
))
const canSubmit = computed(() => (
  !loading.value
  && Boolean(normalizedAddress.value)
  && isAddressFormatValid.value
  && (!isCustomRpcSelected.value || Boolean(normalizedSelectedRpcUrl.value))
  && isCustomRpcUrlValid.value
))

const fillExample = () => {
  address.value = exampleAddress
}

const readJsonResponse = async (response) => {
  try {
    return await response.json()
  } catch {
    return null
  }
}

const fetchBalance = async () => {
  if (!normalizedAddress.value) {
    balance.value = null
    error.value = null
    return
  }

  if (!isAddressFormatValid.value) {
    balance.value = null
    error.value = 'Enter a valid Ethereum address starting with 0x.'
    return
  }

  if (isCustomRpcSelected.value && !normalizedSelectedRpcUrl.value) {
    balance.value = null
    error.value = 'Enter a custom RPC URL or choose a preset RPC node.'
    return
  }

  if (!isCustomRpcUrlValid.value) {
    balance.value = null
    error.value = 'Enter an HTTP(S) RPC URL without credentials or fragments.'
    return
  }

  loading.value = true
  error.value = null
  balance.value = null

  try {
    const encodedAddress = encodeURIComponent(normalizedAddress.value)
    const query = new URLSearchParams()
    if (normalizedSelectedRpcUrl.value) {
      query.set('rpc_url', normalizedSelectedRpcUrl.value)
    }

    const queryString = query.toString()
    const response = await fetch(`${apiBaseUrl}/balance/${encodedAddress}${queryString ? `?${queryString}` : ''}`)
    const data = await readJsonResponse(response)

    if (!response.ok) {
      throw new Error(data?.error || 'Failed to fetch balance')
    }

    if (!data || typeof data.balance_eth === 'undefined') {
      throw new Error('Balance API returned an invalid response')
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
      <label for="rpc-node">RPC Node:</label>
      <select id="rpc-node" v-model="rpcUrl">
        <option v-for="opt in rpcOptions" :key="opt.url" :value="opt.url">
          {{ opt.name }}
        </option>
        <option :value="CUSTOM_RPC_VALUE">Custom RPC URL</option>
      </select>
      <input
        v-if="rpcUrl === CUSTOM_RPC_VALUE"
        v-model="customRpcUrl"
        class="rpc-input"
        type="url"
        placeholder="https://rpc.example.com"
        autocomplete="off"
        aria-label="Custom RPC URL"
        :aria-invalid="normalizedSelectedRpcUrl && !isCustomRpcUrlValid ? 'true' : 'false'"
        aria-describedby="rpc-validation-hint"
      />
    </div>

    <p v-if="isCustomRpcSelected && normalizedSelectedRpcUrl && !isCustomRpcUrlValid" id="rpc-validation-hint" class="validation-hint">
      Custom RPC URLs must use HTTP(S) and cannot include credentials or fragments.
    </p>

    <div class="input-group">
      <label class="sr-only" for="wallet-address">Ethereum wallet address</label>
      <input 
        id="wallet-address"
        v-model="address" 
        placeholder="Enter ETH Address" 
        @keyup.enter="fetchBalance"
        class="address-input"
        autocomplete="off"
        spellcheck="false"
        :aria-invalid="normalizedAddress && !isAddressFormatValid ? 'true' : 'false'"
        aria-describedby="address-validation-hint"
      />
      <button type="button" @click="fetchBalance" :disabled="!canSubmit">
        {{ loading ? 'Checking...' : 'Check Balance' }}
      </button>
    </div>
    
    <div class="example-link">
      <a href="#" @click.prevent="fillExample">Use Example Address</a>
    </div>

    <p v-if="normalizedAddress && !isAddressFormatValid" id="address-validation-hint" class="validation-hint">
      Ethereum addresses must start with 0x and contain 40 hexadecimal characters.
    </p>

    <div v-if="error" class="error" role="alert">
      {{ error }}
    </div>

    <div v-if="balance !== null" class="result" role="status" aria-live="polite">
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

.settings-group label {
  margin-right: 0.5em;
}

.settings-group select,
.rpc-input {
  padding: 0.4em;
  border-radius: 4px;
  border: 1px solid #ccc;
}

.rpc-input {
  margin-left: 0.5em;
  min-width: 260px;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
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

.validation-hint {
  color: #b7791f;
  font-size: 0.9em;
  margin: 0.75em 0;
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
