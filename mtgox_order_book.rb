#!/usr/bin/ruby
require 'csv'
require 'date'
require 'json'
require 'open-uri'

MTGOX_URL = "https://data.mtgox.com/api/1/BTCUSD/depth/full"
ORDERBOOK_JSON = "mtgox_orderbook.json"
OUTPUT_ASK_CSV = "mtgox_ask_output.csv"
OUTPUT_BID_CSV = "mtgox_bid_outpt.csv"

if File.exists? ORDERBOOK_JSON
  orderbook = JSON::load(open ORDERBOOK_JSON)
else
  orderbook = JSON::load(open MTGOX_URL)
  File.open(ORDERBOOK_JSON, "w") do |out|
    JSON::dump orderbook, out
  end
end

def output_orders(filepath, orders)
  CSV.open(filepath, "wb") do |csv|
    csv << ["Date","Price","Amount"]
    orders.each do |order|
      csv << [Time.at(order["stamp"].to_i * 1e-6).utc.to_s,
	      order["price"].to_s,
	      order["amount"].to_s]
    end
  end
end

output_orders OUTPUT_ASK_CSV, orderbook["return"]["asks"]
output_orders OUTPUT_BID_CSV, orderbook["return"]["bids"]
