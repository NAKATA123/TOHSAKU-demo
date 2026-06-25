class Rental < ApplicationRecord
  belongs_to :loaner_car
  belongs_to :repair, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  validates :start_date, presence: true
  validates :end_date, presence: true

  after_create :notify_push

  private

  def notify_push
    customer = customer_name.presence || repair&.car&.customer&.name || "顧客情報なし"
    PushSubscription.broadcast_to_all(
      title: "代車貸出が登録されました",
      body:  "#{loaner_car.name} → #{customer}（#{start_date.strftime('%m/%d')}〜#{end_date.strftime('%m/%d')}）"
    )
  end
  validate :end_date_after_start_date
  validate :no_double_booking

  private

  def end_date_after_start_date
    return unless start_date && end_date
    errors.add(:end_date, "は開始日以降の日付を選択してください") if end_date < start_date
  end

  def no_double_booking
    return unless start_date && end_date

    overlapping = Rental.where(loaner_car_id: loaner_car_id)
                         .where.not(id: id)
                         .where("start_date <= ? AND end_date >= ?", end_date, start_date)

    if overlapping.exists?
      errors.add(:base, "この代車は指定期間にすでに貸出されています")
    end
  end
end
