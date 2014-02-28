require 'sinatra'
require 'sequel'
require './config/environments'
require './models/restaurant'

get '/' do
  puts db.class
end

