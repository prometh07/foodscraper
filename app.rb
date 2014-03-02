require 'sinatra'
require 'sequel'
require './config/environments'
require './models/restaurant'

get '/' do
  'Hello world'
  puts settings.db.class
end

