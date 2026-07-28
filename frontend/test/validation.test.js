import assert from 'node:assert/strict'
import { describe, it } from 'node:test'

import {
  hasValidEthereumAddressFormat,
  hasValidRpcUrlFormat,
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

  it('accepts HTTP(S) RPC URLs with hosts', () => {
    assert.equal(hasValidRpcUrlFormat('https://eth.llamarpc.com'), true)
    assert.equal(hasValidRpcUrlFormat(' http://localhost:8545 '), true)
  })

  it('rejects RPC URLs with unsafe browser-visible components', () => {
    assert.equal(hasValidRpcUrlFormat(''), false)
    assert.equal(hasValidRpcUrlFormat('file:///tmp/socket'), false)
    assert.equal(hasValidRpcUrlFormat('https://token:secret@example.com'), false)
    assert.equal(hasValidRpcUrlFormat('https://example.com/rpc#provider-token'), false)
    assert.equal(hasValidRpcUrlFormat('not a url'), false)
  })
})
