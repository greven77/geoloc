require 'nokogiri'
require 'open-uri'
require 'json'

class AreaCodeMapper
  BASE_URL = "http://dialcode.org"

  ROOT_PAGE = Nokogiri::HTML(open(BASE_URL))
  attr_reader :dial_codes

  def initialize
    if !File.zero?("temp.json") && File.file?("temp.json")
      @dial_codes = load_from_json_file
    else
      @dial_codes = write_to_json_file
    end
  end

  def search_dialcode_city(country, dialcode)
    country = country.downcase
    dialcode = dialcode.to_s
    if !@dial_codes.empty? && @dial_codes[country]
      if ["united states", "canada"].include?(country)
        @dial_codes[country] = @dial_codes[country].values
                               .inject([]) { |a,b| a | b }
      end
      @dial_codes[country].select do |x|
        check_area_code(x, dialcode)
      end
    else
      "Invalid country or empty dialcode database"
    end
  end

private

  def check_area_code(v, dialcode)
    v["area_code"] == dialcode if v.is_a?(Hash)
  end

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
    cities = []
    country_rows = page.css("table tr")
    country_rows[1..-1].each do |country_row|
      name = normalize_text(country_row.css("td")[0].text)
      city  = {}
      city["name"] = normalize_text(country_row.css("td")[0].text)
      city["area_code"] = country_row.css("td")[1].text
      cities << city
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
        secondary_page = Nokogiri::HTML(open(BASE_URL + a['href']))
        link_text = normalize_text(a.text)
        yield(container,link_text, secondary_page)
      end
    end
    container
  end

  def write_to_json_file
    dial_codes = scrape_countries(ROOT_PAGE)

    File.open("temp.json","w") do |f|
      f.write(dial_codes.to_json)
    end
    dial_codes
  end

  def load_from_json_file
    file = File.read("temp.json")
    JSON.parse(file)
  end
end








