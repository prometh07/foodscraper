#encoding: utf-8
require 'mechanize'
require 'pry'
require 'sequel'

Sequel.connect ENV['DATABASE_URL']
require './models/restaurant'
require './models/dish'

class RestaurantFinder < Mechanize
  attr_accessor :cities

  def initialize
    super()
    @cities = ['Poznań']
  end

  def get_restaurants
    cities.each do |city|
      get "http://www.gastronauci.pl/pl/restauracje/#{city}"
      more_restaurants = true
      while more_restaurants do
        puts "Parsing page no. #{page.parser.css("span.current.rounded.element").text}" 
        restaurants = page.parser.css('h3.restaurant_header a').map{|link_obj| link_obj['href']}
        restaurants.each{|restaurant| visit_restaurant restaurant}
        link = page.link_with(text: 'następna') 
        link ? link.click : more_restaurants = false
      end
    end
  end

  def visit_restaurant(restaurant)
    transact do
      get restaurant
      name = page.parser.css('div#restaurant_title a.fn').text.strip
      city = page.parser.css('span.postcode a').text.strip
      street = page.parser.css('span.street').text.strip
      site = page.parser.css('a.www').text.strip
      
      get_website(name, city, street) if name =~ /Restauracja Fryga/

      if !name.end_with?('(zamknięte)') && Restaurant.where(city: city, street: street).count == 0
        site = get_website(name, city, street) if site.empty?
        save_restaurant(name, city, street, site) 
      end
    end
  end

  def save_restaurant(name, city, street, site)
    begin
      Restaurant.create(name: name, city: city, street: street, site: site)
    rescue Sequel::UniqueConstraintViolation => e 
      duplicate_name = Restaurant.where(city: city, street: street).first.name
      puts 'Restaurant with given address already ' \
           "exists: #{duplicate_name}. Current: #{name}" if duplicate_name != name
    end
  end

  def get_website(name, city, street)
    bad_sites = ['maps.google.pl', 'http://www.gastronauci.pl', 'https://pl-pl.facebook.com']
    transact do
      get 'http://www.google.pl' 
      form = page.form('f')
      form.q = "#{name} #{city}".encode(page.encoding, invalid: :replace, undef: :replace)
      submit(form, form.buttons.first)
      site = ''
      page.parser.css('h3.r a').each do |elem|
        site = elem['href']
        binding.pry
        site = site[site.index('http')..site.index('&sa=')-1]
        if bad_sites.any?{|s| site.start_with?(s)}
          site = ''
          next
        end
        break
      end
      site
    end
  end
end

def main
  finder = RestaurantFinder.new
  finder.get_restaurants
end


main()

