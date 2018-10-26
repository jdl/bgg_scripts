#!ruby
# Counts users in a BGG thread.
# 
# pre-reqs
# - ruby 1.9.2
# - nokogiri gem
#
require "nokogiri"
require "httparty"

id = 426060 # MPS / STP thread
#id = 710797 # TCAT

max_batch_size = 500
degraded_batch_size = 25
batch_size = max_batch_size
last_article_id = 0
usernames = {}

counter = 1
article_count = 0

loop do
  url = "https://www.boardgamegeek.com/xmlapi2/thread?id=#{id}&count=#{batch_size}&minarticleid=#{last_article_id}"
  puts "Batch #{counter} - articles: #{article_count} - #{url}"
  response = HTTParty.get(url, timeout: 120)

  if response.code != 200
    puts "Something went wrong"
    puts response
    puts "Pausing 30 seconds"
    batch_size = degraded_batch_size
    sleep 30
   
    next
  else
    doc = Nokogiri::XML(response.body)
    articles = doc.xpath("//thread/articles/article")
    if articles == nil || articles.count < 1
      break
    end

    article_count += articles.count
      
    articles.each do |article|
      last_article_id = article.attributes["id"].value.to_i + 1  # We don't want to see the last article in the next request
      username = article.attributes["username"].value
      if usernames.has_key?(username)
        usernames[username] += 1
      else
        usernames[username] = 1
      end
    end
  end
  counter += 1
  batch_size = max_batch_size
end

puts "Total posts: #{usernames.values.inject(0) {|sum, n| sum += n}}"
puts "Total unique users: #{usernames.keys.count}"
puts "\n-------------------------------------------------------"
puts "post count: username"
puts "-------------------------------------------------------"

usernames.sort {|a,b| b[1] <=> a[1]}.each do |n|
  puts "#{n[1]}: #{n[0]}"
end


