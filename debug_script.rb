require_relative 'crypto_service'

begin
  puts "Testing default..."
  fetcher = CryptoBalanceFetcher.new
  puts "Default created."

  url = 'https://eth.llamarpc.com'
  puts "Testing with URL: #{url}"
  fetcher = CryptoBalanceFetcher.new(rpc_url: url)
  puts "URL created."
  
  address = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'
  puts "Fetching balance..."
  balance = fetcher.call(address)
  puts "Balance: #{balance}"

rescue => e
  puts "CRASHED: #{e.message}"
  puts e.backtrace
end
