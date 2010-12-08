require 'rubygems'
require 'csv'
require 'cgi'
require 'json/pure'
require 'pp'

#open file
file_stream = File.open(ARGV[0]).read
csv = CSV::parse(file_stream)
csv_header = csv.shift

#setup output file
outfile = File.open(ARGV[0].gsub(/\.csv$/,'')+'_results.csv', 'w')
CSV::Writer.generate(outfile) do |output|
  output << ['keyword', 'competition', 'gobal searches', 'local searches', 'allintitle']
end

prev_keyword = ''
keyword = ''
csv.each do |line|
  prev_keyword = keyword
  keyword = line[0]
  next if keyword == prev_keyword
  next if keyword.split(' ').length < 4
  competition = line[1]
  global_searches = line[2]
  local_searches = line.last

  query = "allintitle: #{keyword}"
  encoded_query = CGI::escape(query)
  #response = `curl -e 'http://virusbeater.com' 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{encoded_query}&key=ABQIAAAATa1fIhFuF5xK2DCWMLnvOxRpiK-PblDCB8qilQaqxwz52KVxaBTZp1nvqnsckHx_l2vfa4Tw3REmMA' 2>/dev/null`
  response = `curl 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&gl=us&q=#{encoded_query}&key=ABQIAAAATa1fIhFuF5xK2DCWMLnvOxRpiK-PblDCB8qilQaqxwz52KVxaBTZp1nvqnsckHx_l2vfa4Tw3REmMA' 2>/dev/null`
  #response = `curl -A 'Mozilla/5.0 (Windows; U; Windows NT 6.1; ru; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5' 'http://www.google.com/search?q=#{encoded_query}' 2>/dev/null`
  page = JSON::parse(response)
  allintitle = page['responseData']['cursor']['estimatedResultCount']
  allintitle = '0' if allintitle.nil?
  #match = response.match(/About\s*(.*?)\s*results/)
  #allintitle = match.nil? ? nil : match[1].gsub(/\D/, '')
  
  if allintitle.to_i < 50
    CSV::Writer.generate(outfile) do |output|
      output << [keyword, competition, global_searches, local_searches, allintitle]
    end
  end
  outfile.flush
  sleep(1)
end
