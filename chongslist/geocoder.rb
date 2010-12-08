require 'rubygems'
require 'csv'
require 'json'
require 'cgi'
require 'pp'

outfile = File.open('fixed.csv', 'w')
CSV::Writer.generate(outfile) do |csv|
  csv << ['name', 'address', 'city', 'state', 'zipcode', 'phone', 'hours', 'email', 'website', 'store_front', 'age_range', 'deliver', 'lat', 'lng', 'county']
end

file_stream = File.open('tofix.csv', 'r').read
csv = CSV::parse(file_stream)

csv_header = csv.shift
csv.each do |row|
  neighborhood, name, address, city, state, zipcode, phone, hours, email, website, store_front, age_range, deliver = row
  addr_param = "#{address} #{city} #{state} #{zipcode} USA".gsub("\n", ' ').gsub(/\s+/, ' ')
  #puts '***'
  #puts CGI::escape(addr_param) 
  #puts "curl 'http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{CGI::escape(addr_param)}'"
  response = `curl "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{CGI::escape(addr_param)}" 2>/dev/null`
  geodata = JSON::parse response
  if geodata["status"]=='OK'
    geodata = geodata['results'][0]
    h = {}
    geodata['address_components'].each do |ac|
      if ac['types'].include?('street_number')
        h['g_street_number'] = ac['long_name']
      elsif ac['types'].include?('route')
	h['g_route'] = ac['long_name']
      elsif ac['types'].include?('locality')
	h['g_locality'] = ac['long_name']
      elsif ac['types'].include?('administrative_area_level_2')
	h['g_county'] = ac['long_name']
      elsif ac['types'].include?('administrative_area_level_1')
	h['g_state'] = ac['short_name']
      elsif ac['types'].include?('postal_code')
	h['g_zipcode'] = ac['long_name']
      end
    end
    h['g_lat'] = geodata['geometry']['location']['lat']
    h['g_lng'] = geodata['geometry']['location']['lng']
  end

  #puts "*******"
  #pp h
  unless h.nil?
    address = h['g_street_number'] + ' ' + h['g_route'] if (!h['g_street_number'].nil? && !h['g_route'].nil?)
    city = h['g_locality'] unless h['g_locality'].nil?
    state = h['g_state'] unless h['g_state'].nil?
    county = h['g_county'] unless h['g_county'].nil? 
    zipcode = h['g_zipcode'] unless h['g_zipcode'].nil?
    lat = h['g_lat'].to_s
    lng = h['g_lng'].to_s
  end

  CSV::Writer.generate(outfile) do |csv|
    csv << [name, address, city, state, zipcode, phone, hours, email, website, store_front, age_range, deliver, lat, lng, county]
  end
  
  sleep(1)
end

