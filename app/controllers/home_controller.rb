class HomeController < ApplicationController
  before_action :require_login

  def top
    @reception_count = Repair.reception.count
    @working_count   = Repair.working.count
    @completed_count = Repair.completed.count

    today = Time.zone.today
    @loaned_count = Rental.where("start_date <= ? AND end_date >= ?", today, today).count
    @available_count = [LoanerCar.count - @loaned_count, 0].max

    @today_notice = Notice.find_by(notice_date: today) || Notice.new(notice_date: today)
  end
end
