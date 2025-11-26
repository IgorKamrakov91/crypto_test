require 'spec_helper'
require_relative '../crypto_service'

RSpec.describe CryptoBalanceFetcher do
  let(:rpc_url) { 'https://example.com' }
  let(:service) { described_class.new(rpc_url: rpc_url) }
  let(:valid_address) { '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045' }
  let(:invalid_address) { 'invalid-address' }
  let(:mock_client) { instance_double(Eth::Client) }

  before do
    allow(Eth::Client).to receive(:create).with(rpc_url).and_return(mock_client)
  end

  describe '#initialize' do
    it 'creates an Eth::Client with the provided URL' do
      expect(Eth::Client).to receive(:create).with(rpc_url)
      described_class.new(rpc_url: rpc_url)
    end

    it 'uses the default URL if none is provided' do
      expect(Eth::Client).to receive(:create).with(CryptoBalanceFetcher::DEFAULT_RPC_URL)
      described_class.new
    end
  end

  describe '#call' do
    context 'when the wallet address is valid' do
      let(:balance_wei) { 5_000_000_000_000_000_000 } # 5 ETH
      let(:expected_balance) { BigDecimal('5.0') }

      before do
        allow(Eth::Address).to receive(:new).with(valid_address).and_return(double(valid?: true))
        allow(mock_client).to receive(:get_balance).with(valid_address).and_return(balance_wei)
      end

      it 'fetches the balance and converts it to ETH' do
        expect(service.call(valid_address)).to eq(expected_balance)
      end
    end

    context 'when the wallet address is invalid' do
      before do
        allow(Eth::Address).to receive(:new).with(invalid_address).and_return(double(valid?: false))
      end

      it 'raises an ArgumentError' do
        expect { service.call(invalid_address) }.to raise_error(ArgumentError, /Invalid wallet address/)
      end
    end
  end
end
