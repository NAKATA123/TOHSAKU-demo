class AddReasonToRentals < ActiveRecord::Migration[7.1]
  def change
    add_column :rentals, :reason, :string
  end
end
