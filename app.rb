require 'sinatra'
require 'rack/cors'
require 'ipaddr'
require 'uri'
require_relative 'crypto_service'

DEFAULT_CORS_ORIGIN = 'http://localhost:5173'.freeze
CORS_ORIGINS = ENV.fetch('CORS_ORIGINS', DEFAULT_CORS_ORIGIN)
                  .split(',')
                  .map(&:strip)
                  .reject(&:empty?)
                  .freeze
RPC_HOST_DENYLIST = [
  IPAddr.new('0.0.0.0/8'),
  IPAddr.new('10.0.0.0/8'),
  IPAddr.new('100.64.0.0/10'),
  IPAddr.new('127.0.0.0/8'),
  IPAddr.new('169.254.0.0/16'),
  IPAddr.new('172.16.0.0/12'),
  IPAddr.new('192.168.0.0/16'),
  IPAddr.new('224.0.0.0/4'),
  IPAddr.new('240.0.0.0/4'),
  IPAddr.new('::/128'),
  IPAddr.new('::1/128'),
  IPAddr.new('fc00::/7'),
  IPAddr.new('fe80::/10'),
  IPAddr.new('ff00::/8')
].freeze

# Configure CORS to allow requests from the Vue.js frontend
use Rack::Cors do
  allow do
    origins(*CORS_ORIGINS)
    resource '/health', headers: :any, methods: [:get]
    resource '/balance/*', headers: :any, methods: [:get]
  end
end

# Define the API endpoint to get cryptocurrency balance
get '/health' do
  content_type :json
  cache_control :no_store
  { status: 'ok' }.to_json
end

get '/balance/:address' do
  content_type :json
  cache_control :no_store
  address = params['address'].to_s.strip
  rpc_url = params['rpc_url']

  begin
    rpc_url = normalize_rpc_url(rpc_url)
    service = rpc_url ? CryptoBalanceFetcher.new(rpc_url: rpc_url) : CryptoBalanceFetcher.new
    balance = service.call(address)
    { address: address, balance_eth: balance.to_s('F') }.to_json
  rescue ArgumentError => e
    status 400
    { error: e.message }.to_json
  rescue StandardError => e
    warn "Balance lookup failed: #{e.class}: #{e.message}"
    status 500
    { error: 'Unable to fetch balance from the RPC provider' }.to_json
  end
end

helpers do
  def normalize_rpc_url(value)
    return nil unless value

    url = value.strip
    return nil if url.empty?

    uri = URI.parse(url)
    raise ArgumentError, 'RPC URL must use http or https' unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    raise ArgumentError, 'RPC URL must include a host' unless uri.host && !uri.host.empty?
    raise ArgumentError, 'RPC URL must not include credentials' if uri.userinfo
    raise ArgumentError, 'RPC URL host is not allowed' if private_rpc_host?(uri.host)

    url
  rescue URI::InvalidURIError
    raise ArgumentError, 'Invalid RPC URL'
  end

  def private_rpc_host?(host)
    normalized_host = host.downcase
    return true if normalized_host == 'localhost' || normalized_host.end_with?('.localhost')

    ip_address = IPAddr.new(normalized_host)
    private_or_local_address?(ip_address)
  rescue IPAddr::InvalidAddressError
    false
  end

  def private_or_local_address?(ip_address)
    normalized_ip = if ip_address.ipv4_mapped? || ip_address.ipv4_compat?
                      ip_address.native
                    else
                      ip_address
                    end

    RPC_HOST_DENYLIST.any? { |range| range.include?(normalized_ip) }
  end
end
