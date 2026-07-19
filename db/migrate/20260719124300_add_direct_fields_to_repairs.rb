class AddDirectFieldsToRepairs < ActiveRecord::Migration[7.1]
  def up
    add_column :repairs, :customer_name, :string
    add_column :repairs, :car_model, :string
    add_column :repairs, :car_number, :string

    execute <<~SQL
      UPDATE repairs
      SET customer_name = customers.name,
          car_model = cars.car_model,
          car_number = cars.car_number
      FROM cars
      INNER JOIN customers ON customers.id = cars.customer_id
      WHERE repairs.car_id = cars.id
    SQL

    remove_foreign_key :repairs, :cars
    remove_column :repairs, :car_id
  end

  def down
    add_column :repairs, :car_id, :bigint
    add_foreign_key :repairs, :cars
    remove_column :repairs, :customer_name
    remove_column :repairs, :car_model
    remove_column :repairs, :car_number
  end
end
