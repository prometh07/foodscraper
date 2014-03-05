#encoding: utf-8
require 'mechanize'
require 'pry'
require 'sequel'

Sequel.connect ENV['DATABASE_URL']
require './models/restaurant'
require './models/dish'


class RestaurantFinder < Mechanize
  attr_accessor :cities, :home_page, :db

  def initialize
    super()
    @cities = ["Poznań"]
    @home_page = "http://www.gastronauci.pl/"
    @db = Sequel.connect ENV['DATABASE_URL']
  end

  def get_restaurants
    cities.each do |city|
      page = get "http://www.gastronauci.pl/pl/restauracje/#{city}"
      more_restaurants = true
      while more_restaurants do
        puts "Parsing page no. #{page.parser.css("span.current.rounded.element").text}" 
        restaurants = page.parser.css("h3.restaurant_header a").map{|link_obj| link_obj["href"]}
        restaurants.each{|restaurant| visit_restaurant restaurant}
        link = page.link_with(:text => "następna") 
        link ? page = link.click : more_restaurants = false
      end
    end
  end

  def visit_restaurant restaurant
    page = get restaurant
    name = page.parser.css("div#restaurant_title a.fn").text
    city = page.parser.css("span.postcode a").text
    street = page.parser.css("span.street").text
    site = page.parser.css("a.www").text

    begin
        Restaurant.create(:name => name, :city => city, :street => street, :site => site)
    rescue Sequel::UniqueConstraintViolation => e 
        #if  Restaurant.where(:city => city, :street => street).first.name != name do
    end
  end
end


def main
  finder = RestaurantFinder.new
  finder.get_restaurants
end


main()

