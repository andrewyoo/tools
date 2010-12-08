#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'hpricot'
require 'pp'
require 'date'
require 'mysql'
require 'csv'
require 'htmlentities'

def get_page(url)
  sleep(10)
  `curl -L '#{url}' 2>/dev/null`
end

def extract_data(page)
  doc = Hpricot(page)
  #block = doc.search("//table[@class='fieldGroupTable']")
  block = doc.search("//div[@class='fieldGroup']")
  title = doc.search("//h1[@class='contentheading']").inner_text.strip
  address = block.search("//td[text()*='Dispensary Address']/../td[@class='fieldValue']").inner_text.strip
  city = block.search("//td[text()*='City']/../td[@class='fieldValue']").inner_text.strip
  state = block.search("//td[text()*='State']/../td[@class='fieldValue']").inner_text.strip
  zipcode = block.search("//td[text()*='Zip Code']/../td[@class='fieldValue']").inner_text.strip
  phone = block.search("//td[text()*='Phone Number']/../td[@class='fieldValue']").inner_text.strip
  hours = block.search("//td[text()*='Hours of Operation']/../td[@class='fieldValue']").inner_text.strip
  email_html = block.search("//td[text()*='E-Mail']/../td[@class='fieldValue']").inner_html
  email_front = email_html.match(/var addy.*?'(.*?)'/)
  email_suffix = email_html.match(/addy.*?addy.*?'(.*?)'.*?'(.*?)'.*?'(.*?)'/)
  if !email_front.nil? && !email_suffix.nil?
    coder = HTMLEntities.new
    email = email_front[1] + "@" + email_suffix[1] + email_suffix[2] + email_suffix[3]
    email = coder.decode(email)
  end
  store_front = block.search("//td[text()*='Brick']/../td[@class='fieldValue']").inner_text.strip
  age_range = block.search("//td[text()*='Years Old']/../td[@class='fieldValue']").inner_text.strip
  website = block.search("//td[text()*='Website']/../td[@class='fieldValue']").inner_text.strip
  deliver = block.search("//td[text()*='Deliver']/../td[@class='fieldValue']").inner_text.strip
   #= block.search("/td[text()*='']../td[@class='fieldValue']/span").inner_text.strip
  h = {
    :title => title,
    :address => address,
    :city => city,
    :state => state,
    :zipcode => zipcode,
    :phone => phone,
    :hours => hours,
    :email => email,
    :store_front => store_front,
    :age_range => age_range,
    :website => website,
    :deliver => deliver	}
end

outfile = File.open("weedmaps_data_#{Time.now.strftime("%Y-%m-%d_%H%M%S")}.csv", 'wb')
CSV::Writer.generate(outfile) do |csv|
  csv << ['neighborhood', 'name', 'address', 'city', 'state', 'zipcode', 'phone', 'hours', 'email', 'website', 'store_front', 'age_range', 'deliver']
end
outfile.flush

neighborhoods = []

page = get_page('http://www.weedmaps.com')
doc = Hpricot(page)
links = doc.search("#topnav//a[@rel='canonical'][@class!='disabled']")
links.each do |link|
  match = link.attributes['href'].match(/legalmarijuanadispensary\.com(.*)/)
  unless match.nil?
    n = {	:link => match[0],
      		:name => link.inner_html	}
    neighborhoods << n
  end
end

neighborhoods.each do |n|
  dispensaries = []
  page = get_page n[:link]
  doc = Hpricot(page)
  links = doc.search("//div[@class='jr_tableview']//tr[@class*='row']//td[@class='columnMain']/div[@class='contentTitle']/a")
  links.each do |link|
    d = {	:neighborhood => n[:name],
      		:link => link.attributes['href']	}
    dispensaries << d
  end

  dispensaries.each do |d|
    page = get_page d[:link]
    h = extract_data(page)
    CSV::Writer.generate(outfile) do |csv|
      csv << [n[:name], h[:title], h[:address], h[:city], h[:state], h[:zipcode], h[:phone], h[:hours], h[:email], h[:website], h[:store_front], h[:age_range],  h[:deliver]]
    end
    outfile.flush
  end
end
outfile.close
