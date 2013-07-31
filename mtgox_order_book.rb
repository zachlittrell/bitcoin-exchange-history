require 'csv'
require 'sqlite3'

puts "Opening database..."
order_book = SQLite3::Database.new("dump.sql")
order_book.results_as_hash=true

puts "Finding all possible currencies..."
currencies = order_book.execute("select distinct currency__ 
			       	 from dump")
                       .map{|order| order['Currency__']}

#Apparently, prices in JPY and SEK are stored differently than other 
#currencies
PRICE_UNIT = Hash.new(0.00001)
PRICE_UNIT["JPY"] = 0.001
PRICE_UNIT["SEK"] = 0.001
PRICE_UNIT["BTC"] = 0.00000001 

currencies.each do |currency|
  ["ask","bid"].each do |type|

    puts "Recording #{currency} #{type} orders..."

    CSV.open("mtgox-#{currency}-#{type}-orders.csv",'wb') do |csv|
      csv << ["Date","Num_Of_Orders","Bitcoin_Total","Price_Total"]

      puts "Acquiring orders..."

      order_book.execute("
        SELECT strftime('%Y-%m-%d',Date),
               COUNT(1),
               SUM(Amount)*#{PRICE_UNIT["BTC"]},
               SUM(Price)*#{PRICE_UNIT[currency]}
	       from dump
        WHERE TYPE=='#{type}'
	      and Currency__=='#{currency}'
	      and \"Primary\"=='true'
	GROUP BY strftime('%Y-%m-%d',Date)
	ORDER BY strftime('%Y-%m-%d',Date)") do |day|
	  csv << [day[0],day[1],day[2],day[3]]
	end
    end
  end
end
