require 'nokogiri'
require 'open-uri'
require 'json'

BASE_URL = "http://dialcode.org"

ROOT_PAGE = Nokogiri::HTML(open(BASE_URL))
dial_codes = {}

def normalize_text(text)
  text.downcase.strip.gsub(/\u00a0/, '')
end

def scrape_countries(root_page)
  scrape_locations(root_page) do |dial_codes, country, page|
    country = normalize_text(country)
    if ["united states", "canada"].include?(country)
      dial_codes[country] = scrape_states(page)
    else
      dial_codes[country] = scrape_cities(page)
    end
  end
end

def scrape_cities(page)
  cities = {}
  country_rows = page.css("table tr")
   country_rows[1..-1].each do |country_row|
     city = normalize_text(country_row.css("td")[0].text)
     cities[city] = {}
     cities[city]["name"] = normalize_text(country_row.css("td")[0].text)
     cities[city]["area_code"] = country_row.css("td")[1].text
   end
   cities
end

def scrape_states(country_page)
  scrape_locations(country_page) do |states,state, page|
    states[state] = scrape_cities(page)
  end
end

def scrape_locations(page, container = {})
  rows = page.css('.main .ltopmenu2')
  rows.each do |row|
    row.css("ul li a").each do |a|
      puts a['href']
      secondary_page = Nokogiri::HTML(open(BASE_URL + a['href']))
      link_text = normalize_text(a.text)
      yield(container,link_text, secondary_page)
    end
  end
  container
end

DIAL_CODES = scrape_countries(ROOT_PAGE)
#test the methods keeping all data in a .json file
File.open("temp.json","w") do |f|
  f.write(DIAL_CODES.to_json)
end

