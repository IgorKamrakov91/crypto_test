export const hasValidEthereumAddressFormat = (value) => /^0x[a-fA-F0-9]{40}$/.test(value.trim())

export const normalizeInput = (value) => value.trim()

export const hasValidRpcUrlFormat = (value) => {
  const normalizedValue = normalizeInput(value)

  if (!normalizedValue) {
    return false
  }

  try {
    const url = new URL(normalizedValue)
    return ['http:', 'https:'].includes(url.protocol) && Boolean(url.hostname) && !url.username && !url.password && !url.hash
  } catch {
    return false
  }
}
