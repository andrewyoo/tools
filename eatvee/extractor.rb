#!/usr/bin/env ruby -wKU

if ARGV.length < 1
  puts "usage: ruby extractor.rb '<config name>' '<stage>'"
  exit
end

require 'rubygems'
require 'hpricot'
require 'pp'
require 'date'
require 'mysql'
require 'htmlentities'
require 'logger'
require 'json/pure'

file = File.open(ARGV[0], 'r').read
config = eval(file)[:extractor]

# CONFIG
@db_host = 'localhost'
@db_username = 'root'
@db_password = 'tweettweet'
@db_schema = 'sporq_menulinks'
@user_agent = 'sporqbot v0.1'
@test = ARGV[1] == 'test' ? true : false
@log = Logger.new('logs/extractor.log')
db = Mysql.new @db_host, @db_username, @db_password, @db_schema 

#functions
class NilClass
  def to_sql
    'NULL'
  end
end

class String
  def to_sql
    self.empty? ? 'NULL' : ("'" + self.gsub('\'','\'\'') + "'")
  end
end

def get_page(url)
  sleep(180 + rand(60)) unless @test
  puts "curl -L -m 30 -A '#{@user_agent}' '#{url}' 2>/dev/null" if @test
  `curl -L -m 30 -A '#{@user_agent}' '#{url}' 2>/dev/null`
end

def run_step(doc, field, steps)
  puts "field: " + field.to_s if @test
  steps.each do |s|
    action, v = s
    case action
    when 'xsl'
      doc = doc.search(v)
    when 'attr'
      doc = doc.map { |x| x.attributes[v].gsub(/(^[\r\t\s]+|[\r\t\s]+$)/,'') }
    when 'inner_text'
      doc = doc.map { |x| x.inner_text.gsub(/(^[\r\t\s]+|[\r\t\s]+$)/,'') }
    when 'ruby'
      doc = eval(v)
    end
    puts "action: " + action if @test
    puts "doc: " + doc.class.to_s if @test
  end
  if doc.class == Array
    doc = doc.first if doc.length==1
    doc = nil if doc.length==0
  end
  return [field, doc]
end

#start
pp config if @test
required = [:name, :website, :city, :phone, :state, :address, :menu_link]
begin
  begin
    lf = db.query("select * from link_finder where status='new' and site='#{config[:site]}' limit 1;").fetch_row
    unless lf.nil?
      d = {}
      h = {}
      misc = {}
      id, status, @link, lf_misc = lf
      page = get_page(@link)
      doc = Hpricot(page)

      config[:steps].each do |k,v|
        field, value = run_step(doc, k, v)
        h[field] = value
      end
      pp h

      h.each do |k,v| 
        if required.include? k
          d[k] = v.to_sql
        else
	  misc[k] = v
        end
      end
      misc_str = misc.to_json.to_sql
  
      query = "INSERT INTO restaurant_data (name, website, city, phone, state, address, menu_link, misc, site) values " + 
	      "(#{d[:name]}, #{d[:website]}, #{d[:city]}, #{d[:phone]}, #{d[:state]}, #{d[:address]}, #{d[:menu_link]}, #{misc_str}, #{config[:site].to_sql});"

      if @test
	puts query
      else
        db.query(query) unless h[:menu_link].nil?
        db.query "update link_finder set status='complete' where id=#{id};"
      end
      @log.info query
      exit if @test
    end
    #exit
  end while !lf.nil?
rescue Exception => e
  @log.error e
  exit if @test
end
db.close
