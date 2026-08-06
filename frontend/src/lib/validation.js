export const hasValidEthereumAddressFormat = (value) => /^0x[a-fA-F0-9]{40}$/.test(value.trim())

export const normalizeInput = (value) => value.trim()

const blockedIpv4FirstOctetRanges = [[0, 0], [10, 10], [127, 127], [224, 255]]

const parseIpv4Address = (host) => {
  const parts = host.split('.')
  if (parts.length !== 4 || parts.some((part) => !/^\d+$/.test(part))) {
    return null
  }

  const octets = parts.map(Number)
  return octets.every((octet) => octet >= 0 && octet <= 255) ? octets : null
}

const isPrivateIpv4Address = (host) => {
  const octets = parseIpv4Address(host)
  if (!octets) {
    return false
  }

  const [first, second] = octets
  if (first === 100) {
    return second >= 64 && second <= 127
  }
  if (first === 169) {
    return second === 254
  }
  if (first === 172) {
    return second >= 16 && second <= 31
  }
  if (first === 192) {
    return second === 168 || (second === 0 && (octets[2] === 0 || octets[2] === 2))
  }
  if (first === 198) {
    return (second === 18 || second === 19) || (second === 51 && octets[2] === 100)
  }
  if (first === 203) {
    return second === 0 && octets[2] === 113
  }

  return blockedIpv4FirstOctetRanges.some(([start, end]) => first >= start && first <= end)
}

const isPrivateIpv6Address = (host) => {
  const ipv6Host = host.replace(/^\[|\]$/g, '').toLowerCase()
  return ipv6Host === '::'
    || ipv6Host === '::1'
    || ipv6Host.startsWith('64:ff9b:1:')
    || ipv6Host.startsWith('100:')
    || ipv6Host.startsWith('2001:2:')
    || ipv6Host.startsWith('2001:db8:')
    || ipv6Host.startsWith('fc')
    || ipv6Host.startsWith('fd')
    || ipv6Host.startsWith('fe8')
    || ipv6Host.startsWith('fe9')
    || ipv6Host.startsWith('fea')
    || ipv6Host.startsWith('feb')
    || ipv6Host.startsWith('ff')
    || ipv6Host.startsWith('::ffff:')
}

export const isAllowedRpcHost = (host) => {
  const lowerHost = host.toLowerCase()
  const normalizedHost = lowerHost.includes(':') ? lowerHost : lowerHost.replace(/\.$/, '')

  if (normalizedHost === 'localhost' || normalizedHost.endsWith('.localhost')) {
    return false
  }

  if (normalizedHost.includes(':')) {
    return !isPrivateIpv6Address(normalizedHost)
  }

  return !isPrivateIpv4Address(normalizedHost)
}

export const hasValidRpcUrlFormat = (value) => {
  const normalizedValue = normalizeInput(value)

  if (!normalizedValue) {
    return false
  }

  try {
    const url = new URL(normalizedValue)
    return ['http:', 'https:'].includes(url.protocol)
      && Boolean(url.hostname)
      && !url.username
      && !url.password
      && !url.hash
      && isAllowedRpcHost(url.hostname)
  } catch {
    return false
  }
}
