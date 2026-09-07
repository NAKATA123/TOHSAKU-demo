class SettingsController < ApplicationController
  before_action :require_login

  def index
    @loaner_cars = LoanerCar.order(:created_at)
    @users = User.order(:created_at) if current_user.admin?

    # 貸出履歴（月フィルター＋ページネーション）
    today = Time.zone.today
    @history_month = params[:history_month].presence || today.strftime("%Y-%m")
    month_start = Date.parse("#{@history_month}-01")
    month_end   = month_start.end_of_month
    @all_rentals = Rental
      .includes(:loaner_car, :repair)
      .where("start_date <= ? AND end_date >= ?", month_end, month_start)
      .order(start_date: :desc)
      .page(params[:history_page]).per(100)
  end
end
