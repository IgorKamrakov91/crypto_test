# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'json'
require 'rack/test'
require 'spec_helper'
require_relative '../app'

RSpec.describe 'Balance API' do
  include Rack::Test::Methods

  let(:app) { Sinatra::Application }
  let(:address) { '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045' }
  let(:fetcher) { instance_double(CryptoBalanceFetcher, call: BigDecimal('1.25')) }

  it 'returns a JSON balance for a valid address' do
    expect(CryptoBalanceFetcher).to receive(:new).and_return(fetcher)
    expect(fetcher).to receive(:call).with(address).and_return(BigDecimal('1.25'))

    get "/balance/#{address}"

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq(
      'address' => address,
      'balance_eth' => '1.25'
    )
  end

  it 'passes a non-empty custom RPC URL to the service' do
    rpc_url = 'https://cloudflare-eth.com'

    expect(CryptoBalanceFetcher).to receive(:new).with(rpc_url: rpc_url).and_return(fetcher)

    get "/balance/#{address}", rpc_url: rpc_url

    expect(last_response.status).to eq(200)
  end

  it 'ignores blank custom RPC URLs' do
    expect(CryptoBalanceFetcher).to receive(:new).and_return(fetcher)

    get "/balance/#{address}", rpc_url: '   '

    expect(last_response.status).to eq(200)
  end

  it 'rejects custom RPC URLs with unsupported schemes' do
    expect(CryptoBalanceFetcher).not_to receive(:new)

    get "/balance/#{address}", rpc_url: 'file:///tmp/socket'

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq('error' => 'RPC URL must use http or https')
  end

  it 'rejects malformed custom RPC URLs' do
    expect(CryptoBalanceFetcher).not_to receive(:new)

    get "/balance/#{address}", rpc_url: 'https://bad host'

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq('error' => 'Invalid RPC URL')
  end

  it 'returns a bad request for invalid wallet addresses' do
    expect(CryptoBalanceFetcher).to receive(:new).and_return(fetcher)
    expect(fetcher).to receive(:call).with('bad-address').and_raise(ArgumentError, 'Invalid wallet address: bad-address')

    get '/balance/bad-address'

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq('error' => 'Invalid wallet address: bad-address')
  end
end