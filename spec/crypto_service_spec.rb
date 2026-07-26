require 'spec_helper'
require_relative '../crypto_service'

RSpec.describe CryptoBalanceFetcher do
  let(:http_rpc_url) { 'https://example.com' }
  let(:ipc_rpc_url) { 'ipc://example' }
  let(:valid_address) { '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045' }
  let(:invalid_address) { 'invalid-address' }
  let(:mock_client) { instance_double(Eth::Client) }

  describe '#initialize' do
    it 'stores the provided RPC URL' do
      service = described_class.new(rpc_url: http_rpc_url)

      expect(service.instance_variable_get(:@rpc_url)).to eq(http_rpc_url)
    end

    it 'uses the default RPC URL if none is provided' do
      service = described_class.new

      expect(service.instance_variable_get(:@rpc_url)).to eq(described_class::DEFAULT_RPC_URL)
    end

    it 'uses ETH_RPC_URL from the environment when provided' do
      stub_const('ENV', ENV.to_hash.merge('ETH_RPC_URL' => 'https://rpc.example.test'))

      service = described_class.new

      expect(service.instance_variable_get(:@rpc_url)).to eq('https://rpc.example.test')
    end

    it 'falls back to the default RPC URL when ETH_RPC_URL is blank' do
      stub_const('ENV', ENV.to_hash.merge('ETH_RPC_URL' => '   '))

      service = described_class.new

      expect(service.instance_variable_get(:@rpc_url)).to eq(described_class::DEFAULT_RPC_URL)
    end

    it 'rejects blank RPC URLs' do
      expect { described_class.new(rpc_url: '   ') }.to raise_error(ArgumentError, 'RPC URL cannot be blank')
    end
  end

  describe '#call' do
    before do
      allow(Eth::Address).to receive(:new).with(valid_address).and_return(double(valid?: true))
      allow(Eth::Address).to receive(:new).with(invalid_address).and_return(double(valid?: false))
    end

    context 'when the wallet address is valid' do
      let(:balance_wei) { 5_000_000_000_000_000_000 } # 5 ETH
      let(:expected_balance) { BigDecimal('5.0') }

      it 'fetches the balance over HTTP and converts it to ETH' do
        expect(Eth::Client::Http).to receive(:new).with(http_rpc_url).and_return(mock_client)
        expect(mock_client).to receive(:get_balance).with(valid_address).and_return(balance_wei)

        service = described_class.new(rpc_url: http_rpc_url)

        expect(service.call(valid_address)).to eq(expected_balance)
      end

      it 'trims copied wallet addresses before validation and lookup' do
        padded_address = "  #{valid_address}\n"

        expect(Eth::Address).to receive(:new).with(valid_address).and_return(double(valid?: true))
        expect(Eth::Client::Http).to receive(:new).with(http_rpc_url).and_return(mock_client)
        expect(mock_client).to receive(:get_balance).with(valid_address).and_return(balance_wei)

        service = described_class.new(rpc_url: http_rpc_url)

        expect(service.call(padded_address)).to eq(expected_balance)
      end

      it 'uses Eth::Client.create for non-HTTP RPC URLs' do
        expect(Eth::Client).to receive(:create).with(ipc_rpc_url).and_return(mock_client)
        expect(mock_client).to receive(:get_balance).with(valid_address).and_return(balance_wei)

        service = described_class.new(rpc_url: ipc_rpc_url)

        expect(service.call(valid_address)).to eq(expected_balance)
      end

      it 'preserves fractional ETH precision when converting from wei' do
        balance_wei = 1_234_567_890_123_456_789

        expect(Eth::Client::Http).to receive(:new).with(http_rpc_url).and_return(mock_client)
        expect(mock_client).to receive(:get_balance).with(valid_address).and_return(balance_wei)

        service = described_class.new(rpc_url: http_rpc_url)

        expect(service.call(valid_address)).to eq(BigDecimal('1.234567890123456789'))
      end
    end

    context 'when the wallet address is invalid' do
      it 'raises an ArgumentError' do
        service = described_class.new(rpc_url: http_rpc_url)

        expect { service.call(invalid_address) }.to raise_error(ArgumentError, /Invalid wallet address/)
      end
    end
  end
end
