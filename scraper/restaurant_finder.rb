#encoding: utf-8
require 'mechanize'
require 'pry'
require 'sequel'

Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/foodscraper')
require './models/restaurant'
require './models/dish'


class RestaurantFinder < Mechanize
  attr_accessor :cities, :home_page, :db

  def initialize
    super()
    @cities = ["Poznań"]
    @home_page = "http://www.gastronauci.pl/"
    @db = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/foodscraper')
  end

  def get_restaurants
    cities.each do |city|
      page = get "http://www.gastronauci.pl/pl/restauracje/#{city}"
      more_restaurants = true
      while more_restaurants do
        restaurants = page.parser.css('div#search_results ul h3.restaurant_header a').map{|link_obj| link_obj['href']}
        restaurants.each{|restaurant| visit_restaurant restaurant}
        link = page.link_with(:text => "następna") 
        link ? page = link.click : more_restaurants = false
      end
    end
  end

  def visit_restaurant restaurant
    page = get restaurant
  end
end


def main
  finder = RestaurantFinder.new
  finder.get_restaurants
end


main()

