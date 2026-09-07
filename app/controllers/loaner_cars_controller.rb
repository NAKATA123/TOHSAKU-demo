class LoanerCarsController < ApplicationController
  before_action :require_login
  before_action :set_loaner_car, only: [:edit, :update, :destroy]

  # 一覧（タブ切り替え＋グリッド）
  def index
    @loaner_cars = LoanerCar.includes(:rentals).order(created_at: :desc)
    today = Time.zone.today

    # グリッド用（2週間）
    @grid_start = params[:start_date].present? ? Date.parse(params[:start_date]) : today
    @grid_end   = @grid_start + 13.days
    @grid_dates = (@grid_start..@grid_end).to_a

    grid_rentals = Rental
      .includes(:repair)
      .where("start_date <= ? AND end_date >= ?", @grid_end, @grid_start)
    @rental_by_car = grid_rentals.group_by(&:loaner_car_id)

    # グリッドの並び順（貸出予定が一番遠い車を上に。貸出予定がない車はさらに上）
    @grid_sort = params[:grid_sort] == "asc" ? "asc" : "desc"
    no_schedule_cars, scheduled_cars = @loaner_cars.partition { |car| @rental_by_car[car.id].blank? }
    scheduled_cars.sort_by! { |car| @rental_by_car[car.id].map(&:end_date).max }.reverse!
    grid_cars_desc = no_schedule_cars + scheduled_cars
    @grid_cars = @grid_sort == "asc" ? grid_cars_desc.reverse : grid_cars_desc

    # 貸出中
    @current_rentals = Rental
      .includes(:loaner_car, :repair, :created_by)
      .where("start_date <= ? AND end_date >= ?", today, today)
      .order(:start_date)

    # 貸出履歴（月フィルター＋ページネーション）
    @history_month = params[:history_month].presence || today.strftime("%Y-%m")
    month_start = Date.parse("#{@history_month}-01")
    month_end   = month_start.end_of_month
    @all_rentals = Rental
      .includes(:loaner_car, :repair)
      .where("start_date <= ? AND end_date >= ?", month_end, month_start)
      .order(start_date: :desc)
      .page(params[:history_page]).per(100)

    # 駐車場別グループ
    @cars_by_lot = @loaner_cars.group_by { |c| c.parking_lot.presence || "未設定" }

    # 貸出予定
    @upcoming_sort = params[:upcoming_sort] == "date" ? "date" : "created"
    upcoming_order = @upcoming_sort == "date" ? { start_date: :asc } : { created_at: :desc }
    @upcoming_rentals = Rental
      .includes(:loaner_car, :created_by, :repair)
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
      redirect_to settings_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @loaner_car.update(loaner_car_params)
      redirect_to settings_path, notice: "代車情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @loaner_car.destroy
    redirect_to settings_path, notice: "代車を削除しました"
  end

  private

  def set_loaner_car
    @loaner_car = LoanerCar.find(params[:id])
  end

  def loaner_car_params
    params.require(:loaner_car).permit(:name, :car_number, :parking_lot)
  end
end
