class Car < ApplicationRecord
  belongs_to :customer
  has_many :repairs, dependent: :destroy
end
