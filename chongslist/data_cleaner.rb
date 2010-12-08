require 'rubygems'
require 'csv'
require 'json'
require 'cgi'
require 'pp'

#outfile = File.open('cleaned.csv', 'w')
#CSV::Writer.generate(outfile) do |csv|
#  csv << ['name', 'address', 'city', 'state', 'zipcode', 'phone', 'hours', 'email', 'website', 'store_front', 'age_range', 'deliver', 'lat', 'lng', 'county']
#end

file_stream = File.open('fixed.csv', 'r').read
csv = CSV::parse(file_stream)

csv_header = csv.shift
csv.each do |row|
  name, address, city, state, zipcode, phone, hours, email, website, store_front, age_range, deliver, lat, lng, county = row
  addr_param = "#{address} #{city} #{state} #{zipcode} USA".gsub("\n", ' ').gsub(/\s+/, ' ')

  phone.gsub!(/\D/, '') unless phone.nil?
  phone = phone.reverse.chop.reverse if (!phone.nil? and phone.length == 11 and phone[0].chr == '1')
  phone = nil if phone==''
 
  unless county.nil?
    puts state.to_s + ', ' + county.to_s
    #CSV::Writer.generate(outfile) do |csv|
    #  csv << [name, address, city, state, zipcode, phone, hours, email, website, store_front, age_range, deliver, lat, lng, county]
    #end
  end 
end

