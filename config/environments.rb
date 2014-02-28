configure do
  db = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/foodscraper')
  set :db, db
end

