require 'eth'
require 'bigdecimal'

# Fetches the cryptocurrency balance for a given wallet address from an Ethereum RPC node.
class CryptoBalanceFetcher
  DEFAULT_RPC_URL = 'https://eth.llamarpc.com'.freeze
  WEI_IN_ETH = BigDecimal(10**18)

  def self.default_rpc_url
    configured_url = ENV.fetch('ETH_RPC_URL', '').strip
    configured_url.empty? ? DEFAULT_RPC_URL : configured_url
  end

  def initialize(rpc_url: self.class.default_rpc_url)
    @rpc_url = rpc_url.to_s.strip
    raise ArgumentError, 'RPC URL cannot be blank' if @rpc_url.empty?
  end

  def call(wallet_address)
    normalized_address = wallet_address.to_s.strip
    raise ArgumentError, "Invalid wallet address: #{wallet_address}" unless Eth::Address.new(normalized_address).valid?

    balance_wei = rpc_client.get_balance(normalized_address)
    BigDecimal(balance_wei) / WEI_IN_ETH
  end

  private

  def rpc_client
    return Eth::Client::Http.new(@rpc_url) if http_rpc_url?

    Eth::Client.create(@rpc_url)
  end

  def http_rpc_url?
    @rpc_url.match?(%r{\Ahttps?://}i)
  end
end
