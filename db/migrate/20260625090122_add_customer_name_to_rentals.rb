class AddCustomerNameToRentals < ActiveRecord::Migration[7.1]
  def change
    add_column :rentals, :customer_name, :string
  end
end
