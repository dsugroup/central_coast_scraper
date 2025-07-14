# encoding: UTF-8
require 'mechanize'
require 'date'
require 'scraperwiki'

agent = Mechanize.new
base_url = 'https://www.centralcoast.nsw.gov.au/council/news-and-publications/news/current-development-applications'
page = agent.get(base_url)

DA_set = page.search("table#tablefield-paragraphs_item-2193-field_p_table-0/tbody/tr")

# 🧠 Keywords to filter relevant development applications
keywords = ['subdivision', 'rezoning', 'boundary adjustment', 'land clearing', 'urban release']

DA_set.each do |row|
  record = {}
  rowSet = row.search("td")
  record['council_reference'] = rowSet[0].text
  record['date_submitted'] = rowSet[1].text
  record['address'] = rowSet[2].text
  record['description'] = rowSet[4].text.gsub("&amp;", "&")
  record['date_scraped'] = Date.today.to_s

  description = record['description'].downcase
  keyword_match = keywords.any? { |word| description.include?(word.downcase) }

  if keyword_match
    ScraperWiki.save_sqlite(['council_reference'], record)
    puts "✅ Saved match: #{record['council_reference']}"
  else
    puts "⏭️ Skipped: #{record['council_reference']}" if ENV['DEBUG']
  end
end
