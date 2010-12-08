#!/usr/bin/env ruby -wKU

if ARGV.length < 1
  puts "usage: ruby linkfinder.rb '<config name>' '<stage>'"
  exit
end

require 'rubygems'
require 'hpricot'
require 'pp'
require 'date'
require 'mysql'
require 'htmlentities'
require 'logger'

file = File.open(ARGV[0], 'r').read
config = eval(file)[:linkfinder]

# CONFIG
@db_host = 'localhost'
@db_username = 'root'
@db_password = 'tweettweet'
@db_schema = 'sporq_menulinks'
@user_agent = 'sporqbot v0.1'
@test = ARGV[1] == 'test' ? true : false
@log = Logger.new('logs/linkfinder.log')
db = Mysql.new @db_host, @db_username, @db_password, @db_schema 

#functions
def get_page(url)
  sleep(5)
  #sleep(180 + rand(60)) unless @test
  puts "curl -L -m 30 -A '#{@user_agent}' '#{url}' 2>/dev/null" if @test
  `curl -L -m 30 -A '#{@user_agent}' '#{url}' 2>/dev/null`
end

def run_step(doc, field, steps)
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
  return [field, doc]
end

#start
pp config if @test
if !config[:start_urls].nil?
  config[:start_urls].each do |su|
    begin
      h = {}
      page = get_page(su)
      #page = File.open('sitemap-1.xml', 'r').read
      doc = Hpricot(page)
      config[:steps].each do |k,v|
        field, value = run_step(doc, k, v)
	h[field] = value
      end

      h[:extract_url].each do |v|
	if v =~ /^\//
	  v = config[:base_url] + v
	elsif v !~ /^http/
	  v = config[:base_url] + '/' + v
	end

        if @test
          puts "insert ignore into link_finder (extract_url, site) values ('#{v}', '#{config[:site]}');"
        else
          db.query "insert ignore into link_finder (extract_url, site) values ('#{v}', '#{config[:site]}');"
        end
      end
      exit if @test
  
    rescue Exception => e
      @log.error e
      exit if @test
    end
  end
end

db.close
