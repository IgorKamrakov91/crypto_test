require 'eth'
require 'bigdecimal'

# Fetches the cryptocurrency balance for a given wallet address from an Ethereum RPC node.
class CryptoBalanceFetcher
  DEFAULT_RPC_URL = 'https://eth.llamarpc.com'.freeze
  WEI_IN_ETH = BigDecimal(10**18)

  def initialize(rpc_url: DEFAULT_RPC_URL)
    @rpc_url = rpc_url.to_s.strip
  end

  def call(wallet_address)
    raise ArgumentError, "Invalid wallet address: #{wallet_address}" unless Eth::Address.new(wallet_address).valid?

    client = if @rpc_url.match?(/^http/i)
               Eth::Client::Http.new(@rpc_url)
             else
               Eth::Client.create(@rpc_url)
             end

    balance_wei = client.get_balance(wallet_address)
    BigDecimal(balance_wei) / WEI_IN_ETH
  end
end
