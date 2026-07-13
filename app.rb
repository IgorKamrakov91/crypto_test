require 'sinatra'
require 'rack/cors'
require 'uri'
require_relative 'crypto_service'

# Configure CORS to allow requests from the Vue.js frontend
use Rack::Cors do
  allow do
    origins 'http://localhost:5173' # Adjust this to your Vue.js development server's address and port
    resource '/balance/*', headers: :any, methods: [:get]
  end
end

# Define the API endpoint to get cryptocurrency balance
get '/balance/:address' do
  content_type :json
  address = params['address']
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
    status 500
    { error: e.message }.to_json
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

    url
  rescue URI::InvalidURIError
    raise ArgumentError, 'Invalid RPC URL'
  end
end
