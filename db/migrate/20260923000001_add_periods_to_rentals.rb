class AddPeriodsToRentals < ActiveRecord::Migration[7.1]
  def change
    add_column :rentals, :start_period, :string, default: "am", null: false
    add_column :rentals, :end_period, :string, default: "pm", null: false
  end
end
