require 'nokogiri'
require 'open-uri'

BASE_URL = "http://dialcode.org/"

root_page = Nokogiri::HTML(open(BASE_URL))
dial_codes = {}

def scrape_countries(root_page)
  scrape_locations(root_page) do |dial_codes, country, page|
    if ["united states", "canada"].contains?(country.downcase)
      dial_codes[country] = scrape_states(page)
    else
      dial_codes[country] = scrape_cities(page)
    end
  end
end

def scrape_cities(page)
  cities = {}
  country_rows = page.css("table tr")
   country_rows[1..-2].each do |country_row|
     city = country_row.css("td")[0].downcase
     cities[city] = {}
     cities[city]["name"] = country_row.css("td")[0]
     cities[city]["area_code"] = country_row.css("td")[1]
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
    row.css("ul li a") do |a|
      secondary_page = Nokogiri::HTML(open(BASE_URL + a['href']))
      link_text = a.text
      yield(container,link_text, secondary_page)
    end
  end
  container
end
