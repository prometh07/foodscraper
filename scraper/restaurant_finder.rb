#encoding: utf-8
require 'mechanize'
require 'pry'
require 'sequel'

Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/foodscraper')
require './models/restaurant'
require './models/dish'


class RestaurantFinder < Mechanize
  attr_accessor :cities, :home_page, :page, :db

  def initialize
    super()
    @cities = ["Poznań"]
    @home_page = "http://www.gastronauci.pl/"
    @page = get home_page
    @db = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/foodscraper')
  end

  def get_restaurants
    cities.each do |city|
      page = get "http://www.gastronauci.pl/pl/restauracje/#{city}"
      more_restaurants = true
      while more_restaurants do
        link = page.link_with(:text => "następna") 
        link ? page = link.click : more_restaurants = false
      end
    end
  end
end


def main
  finder = RestaurantFinder.new
  finder.get_restaurants
end


main()
