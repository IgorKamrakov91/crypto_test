require 'eth'
require 'bigdecimal'

# Fetches the cryptocurrency balance for a given wallet address from an Ethereum RPC node.
class CryptoBalanceFetcher
  DEFAULT_RPC_URL = 'https://eth.llamarpc.com'.freeze
  WEI_IN_ETH = BigDecimal(10**18)

  def initialize(rpc_url: DEFAULT_RPC_URL)
    @client = Eth::Client.create(rpc_url)
  end

  def call(wallet_address)
    raise ArgumentError, "Invalid wallet address: #{wallet_address}" unless Eth::Address.new(wallet_address).valid?

    balance_wei = @client.get_balance(wallet_address)
    BigDecimal(balance_wei) / WEI_IN_ETH
  end
end

# Example usage
vitalik_wallet = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'
service = CryptoBalanceFetcher.new

begin
  puts "--- Get balance: #{vitalik_wallet} ---"
  balance = service.call(vitalik_wallet)
  puts "Balance (Eth): #{balance.to_s('F')}"
rescue StandardError => e
  puts "Error: #{e.message}"
end
