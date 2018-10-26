#!ruby
# Counts thumbs in a BGG thread.
# 
# pre-reqs
# - ruby 2.3.0
# - nokogiri gem
# - httparty gem
#
require "nokogiri"
require "httparty"
require "byebug"

id = 426060  # MSP/STP thread
page = 1
delay = 5 # pause between gets so we don't spam BGG


thumbs_by_username = {}

def username(article_elem)
  article_elem.css("div.avatarblock").first.attributes["data-username"].value
end

def thumbs(article_elem)
  article_elem.css("dt.recs").text.to_i
end

def last_page?(doc)
  doc.css("a[title^='next page']").count < 1
end

loop do
  url = "https://www.boardgamegeek.com/thread/#{id}/page/#{page}"
  puts url

  response = HTTParty.get(url, timeout: 120)
  if response.code != 200
    puts "error"
    puts response.code
    break
  else
    doc = Nokogiri::HTML(response.body)

    articles = doc.css("div.article")
    puts "  found #{articles.count} articles"

    articles.each do |a|
      username = username(a)
      t_count = thumbs(a)

      if thumbs_by_username.has_key?(username)
        thumbs_by_username[username] += t_count
      else
        thumbs_by_username[username] = t_count
      end
    end
  end

  if last_page?(doc) || page > 2
    break
  else
    page += 1
    sleep delay
  end

end

puts thumbs_by_username


puts "Total thumbs: #{thumbs_by_username.values.inject(0) {|sum, n| sum += n}}"
puts "Total unique users: #{thumbs_by_username.keys.count}"
puts "\n-------------------------------------------------------"
puts "rank:\t [thumbs]\t username"
puts "-------------------------------------------------------"

thumbs_by_username.sort {|a,b| b[1] <=> a[1]}.each_with_index do |n, index|
  puts "#{index + 1}:\t [#{n[1]}]\t #{n[0]}"
end
