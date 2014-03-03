Sequel.migration do
  up do
    create_table :restaurants do
      primary_key :id
      String :name
      String :city
      String :street
      String :site
    end

    create_table :dishes do
      primary_key :id
      foreign_key :restaurant_id, :restaurants
      String :dish, :text => true
      Integer :price
    end
  end

  down do
    drop_table :dishes
    drop_table :restaurants
  end
end
