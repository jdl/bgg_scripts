#!ruby
# Counts users in a BGG thread.
# 
# pre-reqs
# - ruby 1.9.2
# - nokogiri gem
#
require "nokogiri"
require "net/http"

url = URI.parse("http://www.boardgamegeek.com/xmlapi2/thread?id=426060")
response = Net::HTTP.start(url.host, url.port) do |http|
  http.get(url.path + "?" + url.query)
end

if response.code != "200"
  puts "Something went wrong"
else
  usernames = {}
  doc = Nokogiri::XML(response.body)
  doc.xpath("//thread/articles/article").each do |article|
    username = article.attributes["username"].value
    if usernames.has_key?(username)
      usernames[username] += 1
    else
      usernames[username] = 1
    end
  end
  puts "Total posts: #{usernames.values.inject(0) {|sum, n| sum += n}}"
  puts "Total unique users: #{usernames.keys.count}"
  puts "\n-------------------------------------------------------"
  puts "post count: username"
  puts "-------------------------------------------------------"

  usernames.sort {|a,b| b[1] <=> a[1]}.each do |n|
    puts "#{n[1]}: #{n[0]}"
  end
end


