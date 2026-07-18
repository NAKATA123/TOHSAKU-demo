class AddParkingLotToLoanerCars < ActiveRecord::Migration[7.1]
  def change
    add_column :loaner_cars, :parking_lot, :string
  end
end
