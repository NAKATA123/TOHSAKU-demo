class LoanerCar < ApplicationRecord
  has_many :rentals, dependent: :destroy

  PARKING_LOTS = { "A" => "現場", "B" => "勝山", "C" => "東大阪" }.freeze

  validates :parking_lot, inclusion: { in: PARKING_LOTS.keys }, allow_blank: true
end
