class AddPositionToLoanerCars < ActiveRecord::Migration[7.1]
  def up
    add_column :loaner_cars, :position, :integer

    LoanerCar.reset_column_information
    LoanerCar.order(:created_at).each_with_index do |car, index|
      car.update_column(:position, index)
    end
  end

  def down
    remove_column :loaner_cars, :position
  end
end
