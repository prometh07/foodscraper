#encoding: utf-8
require 'mechanize'


class RestaurantFinder < Mechanize
  attr_accessor :cities, :home_page

  def initialize
    super()
    @cities = ["Poznań"]
    @home_page = "http://www.gastronauci.pl/"
    @page = get home_page
  end

  def get_restaurants
    cities.each do |city|
      goto_list_of_restaurants city
      more_restaurants = true
      while more_restaurants do
        # extract data
        link = page.link_with(:text => "następna") ? page = link.click : more_restaurants = false
      end
    end
  end

  def goto_list_of_restaurants city
    page = get home_page
    page.forms[0].city = city
    page = submit page.forms[0]
  end
end


def main
  finder = RestaurantFinder.new
  finder.get_restaurants
end


main()
