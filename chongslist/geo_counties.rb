require 'rubygems'
require 'csv'
require 'json'
require 'cgi'
require 'pp'

outfile = File.open('counties_done2', 'w')

File.open('counties', 'r').each do |row|
  row.strip!
  state_code, county = row.split(',')
  next if county == ' County'
  addr = "#{county} county #{state_code} USA"
puts addr
  resp = `curl "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{CGI::escape(addr)}"`
puts resp

  data = JSON::parse(resp)
  lat = data['results'][0]['geometry']['location']['lat']
  lng = data['results'][0]['geometry']['location']['lng']
  outfile.puts "#{row}, #{lat}, #{lng}"
break
  sleep(1)
end

