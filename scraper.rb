# encoding: UTF-8
require 'mechanize'
require 'date'
require 'scraperwiki'

agent = Mechanize.new
base_url = 'https://www.centralcoast.nsw.gov.au/council/news-and-publications/news/current-development-applications'
page = agent.get(base_url)

DA_set = page.search("table#tablefield-paragraphs_item-2193-field_p_table-0/tbody/tr")

# 🏡 Your target suburbs
target_suburbs = ['Wadalba', 'Warnervale', 'Bonnells Bay', 'Watanobbi', 'Cooranbong']
# 🧠 Keywords indicating potential land release
keywords = ['subdivision', 'rezoning', 'boundary adjustment', 'land clearing', 'urban release']

DA_set.each do |row|
  record = {}
  rowSet = row.search("td")
  record['council_reference'] = rowSet[0].text
  record['date_submitted'] = rowSet[1].text
  record['address'] = rowSet[2].text
  record['description'] = rowSet[4].text.gsub("&amp;", "&")
  record['date_scraped'] = Date.today.to_s

  address = record['address'].downcase
  description = record['description'].downcase

  suburb_match = target_suburbs.any? { |suburb| address.include?(suburb.downcase) }
  keyword_match = keywords.any? { |word| description.include?(word.downcase) }

  if suburb_match && keyword_match
    ScraperWiki.save_sqlite(['council_reference'], record)
    puts "✅ Saved match: #{record['council_reference']}"
  else
    puts "⏭️ Skipped: #{record['council_reference']}" if ENV['DEBUG']
  end
end
