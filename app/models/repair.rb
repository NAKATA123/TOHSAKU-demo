class Repair < ApplicationRecord
  has_many :rentals, dependent: :destroy

  enum status: { reception: 0, working: 1, completed: 2 }

  validates :customer_name, presence: true

  def next_status
    { "reception" => "working", "working" => "completed" }[status]
  end

  def next_status_label
    { "reception" => "作業開始 →", "working" => "完了にする ✓" }[status]
  end
end
