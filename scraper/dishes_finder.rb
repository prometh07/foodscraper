#encoding: utf-8
require 'mechanize'
require 'pry'
require 'sequel'

Sequel.connect ENV['DATABASE_URL']
require './models/restaurant'
require './models/dish'

class DishesFinder < Mechanize
  def initialize
    super()
    @db = Sequel.connect ENV['DATABASE_URL']
  end
end
