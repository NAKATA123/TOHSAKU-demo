class Rental < ApplicationRecord
  belongs_to :loaner_car
  belongs_to :repair, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  PERIODS = %w[am pm].freeze

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :start_period, inclusion: { in: PERIODS }
  validates :end_period, inclusion: { in: PERIODS }
  validate :end_date_after_start_date
  validate :no_double_booking

  after_create :notify_push

  # 半日単位の通し番号（同じ日のam/pmを比較できるようにする）
  def start_slot
    slot_for(start_date, start_period)
  end

  def end_slot
    slot_for(end_date, end_period)
  end

  # 「今」が属する半日スロット（貸出中かどうかの判定に使う）
  def self.current_slot
    now = Time.zone.now
    now.to_date.jd * 2 + (now.hour < 12 ? 0 : 1)
  end

  private

  def slot_for(date, period)
    return nil unless date
    date.jd * 2 + (period == "pm" ? 1 : 0)
  end

  def notify_push
    customer = customer_name.presence || repair&.customer_name || "顧客情報なし"
    PushSubscription.broadcast_to_all(
      title: "代車貸出が登録されました",
      body:  "#{loaner_car.name} → #{customer}（#{start_date.strftime('%m/%d')}〜#{end_date.strftime('%m/%d')}）"
    )
  end

  def end_date_after_start_date
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, "は開始日以降の日付を選択してください")
    elsif end_date == start_date && end_slot < start_slot
      errors.add(:end_date, "の午前/午後が開始日と矛盾しています")
    end
  end

  def no_double_booking
    return unless start_date && end_date

    candidates = Rental.where(loaner_car_id: loaner_car_id)
                        .where.not(id: id)
                        .where("start_date <= ? AND end_date >= ?", end_date, start_date)

    overlapping = candidates.any? { |other| start_slot <= other.end_slot && end_slot >= other.start_slot }

    errors.add(:base, "この代車は指定期間にすでに貸出されています") if overlapping
  end
end
