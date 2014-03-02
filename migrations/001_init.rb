Sequel.migration do
  up do
    create_table :restaurants do
      primary_key :id
      String :name, :text => true
      String :city
      String :Street
      String :site
    end

    create_table :dishes do
      primary_key :id
      foreign_key :restaurant_id, :restaurants
      String :dish
      Integer :price
    end
  end

  down do
    drop_table :restaurants
    drop_table :dishes
  end
end
