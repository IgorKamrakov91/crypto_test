import assert from 'node:assert/strict'
import { describe, it } from 'node:test'

import {
  hasValidEthereumAddressFormat,
  hasValidRpcUrlFormat,
  isAllowedRpcHost,
  normalizeInput
} from '../src/lib/validation.js'

describe('validation helpers', () => {
  it('trims copied text inputs', () => {
    assert.equal(normalizeInput('  value\n'), 'value')
  })

  it('accepts canonical Ethereum address strings', () => {
    assert.equal(hasValidEthereumAddressFormat('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'), true)
  })

  it('rejects malformed Ethereum address strings', () => {
    assert.equal(hasValidEthereumAddressFormat('d8dA6BF26964aF9D7eEd9e03E53415D37aA96045'), false)
    assert.equal(hasValidEthereumAddressFormat('0xnot-an-address'), false)
    assert.equal(hasValidEthereumAddressFormat(''), false)
  })

  it('accepts HTTP(S) RPC URLs with public hosts', () => {
    assert.equal(hasValidRpcUrlFormat('https://eth.llamarpc.com'), true)
    assert.equal(hasValidRpcUrlFormat(' https://rpc.ankr.com/eth '), true)
  })

  it('rejects RPC URLs with unsafe browser-visible components', () => {
    assert.equal(hasValidRpcUrlFormat(''), false)
    assert.equal(hasValidRpcUrlFormat('file:///tmp/socket'), false)
    assert.equal(hasValidRpcUrlFormat('https://token:secret@example.com'), false)
    assert.equal(hasValidRpcUrlFormat('https://example.com/rpc#provider-token'), false)
    assert.equal(hasValidRpcUrlFormat('not a url'), false)
  })

  it('rejects localhost, private, and reserved RPC hosts', () => {
    assert.equal(hasValidRpcUrlFormat('http://localhost:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://api.localhost:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://localhost.:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://api.localhost.:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://10.0.0.5:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://172.20.0.5:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://192.168.1.10:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://127.1:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://192.0.2.10:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://198.18.0.1:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://198.51.100.10:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://203.0.113.5:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://[::1]:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://[fc00::1]:8545'), false)
    assert.equal(hasValidRpcUrlFormat('http://[2001:db8::1]:8545'), false)
  })

  it('allows public IPv4 hosts near private range boundaries', () => {
    assert.equal(hasValidRpcUrlFormat('https://100.128.0.1'), true)
    assert.equal(hasValidRpcUrlFormat('https://169.255.1.1'), true)
    assert.equal(hasValidRpcUrlFormat('https://172.32.0.1'), true)
    assert.equal(hasValidRpcUrlFormat('https://192.0.3.10'), true)
  })

  it('classifies RPC host safety consistently', () => {
    assert.equal(isAllowedRpcHost('eth.llamarpc.com'), true)
    assert.equal(isAllowedRpcHost('localhost'), false)
    assert.equal(isAllowedRpcHost('localhost.'), false)
    assert.equal(isAllowedRpcHost('100.64.10.1'), false)
    assert.equal(isAllowedRpcHost('[fe80::1]'), false)
  })
})
