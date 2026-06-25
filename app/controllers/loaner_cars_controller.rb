class LoanerCarsController < ApplicationController
  before_action :require_login
  before_action :set_loaner_car, only: [:edit, :update, :destroy]

  # 一覧（タブ切り替え＋グリッド）
  def index
    @loaner_cars = LoanerCar.all.order(created_at: :desc)
    today = Time.zone.today

    # グリッド用（2週間）
    @grid_start = params[:start_date].present? ? Date.parse(params[:start_date]) : today
    @grid_end   = @grid_start + 13.days
    @grid_dates = (@grid_start..@grid_end).to_a

    grid_rentals = Rental
      .includes(repair: { car: :customer })
      .where("start_date <= ? AND end_date >= ?", @grid_end, @grid_start)
    @rental_by_car = grid_rentals.group_by(&:loaner_car_id)

    # 貸出中
    @current_rentals = Rental
      .includes(:loaner_car, repair: { car: :customer })
      .where("start_date <= ? AND end_date >= ?", today, today)
      .order(:start_date)

    # 貸出履歴（月フィルター＋ページネーション）
    @history_month = params[:history_month].presence || today.strftime("%Y-%m")
    month_start = Date.parse("#{@history_month}-01")
    month_end   = month_start.end_of_month
    @all_rentals = Rental
      .includes(:loaner_car, :created_by, repair: { car: :customer })
      .where("start_date <= ? AND end_date >= ?", month_end, month_start)
      .order(start_date: :desc)
      .page(params[:history_page]).per(100)

    # 貸出予定
    @upcoming_sort = params[:upcoming_sort] == "date" ? "date" : "created"
    upcoming_order = @upcoming_sort == "date" ? { start_date: :asc } : { created_at: :desc }
    @upcoming_rentals = Rental
      .includes(:loaner_car, :created_by, repair: { car: :customer })
      .where("start_date > ?", today)
      .order(upcoming_order)
  end

  # 新規登録フォーム
  def new
    @loaner_car = LoanerCar.new
  end

  # 登録
  def create
    @loaner_car = LoanerCar.new(loaner_car_params)
    if @loaner_car.save
      redirect_to loaner_cars_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @loaner_car.update(loaner_car_params)
      redirect_to loaner_cars_path, notice: "代車情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @loaner_car.destroy
    redirect_to loaner_cars_path, notice: "代車を削除しました"
  end

  private

  def set_loaner_car
    @loaner_car = LoanerCar.find(params[:id])
  end

  def loaner_car_params
    params.require(:loaner_car).permit(:name, :car_number, :shaken_expiry_date)
  end
end
