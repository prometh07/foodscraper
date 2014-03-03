class Restaurant < Sequel::Model :restaurants
  one_to_many :dishes
end
