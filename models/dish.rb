class Dish < Sequel::Model :dishes
  many_to_one :restaurant
end
