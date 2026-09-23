class RentalsController < ApplicationController
  before_action :require_login

  def new
    @repair = Repair.find_by(id: params[:repair_id])
    @rental = Rental.new(start_date: params[:start_date], loaner_car_id: params[:loaner_car_id])
    @loaner_cars = LoanerCar.all
  end

  def create
    @rental = Rental.new(rental_params)
    @rental.created_by = current_user

    if @rental.save
      @rental.loaner_car.update(parking_lot: params[:parking_lot]) if params.key?(:parking_lot)

      if @rental.repair.present?
        redirect_to repair_path(@rental.repair), notice: "代車を登録しました"
      else
        redirect_to loaner_cars_path, notice: "代車を登録しました"
      end
    else
      @repair = Repair.find_by(id: @rental.repair_id)
      @loaner_cars = LoanerCar.all
      render :new, status: :unprocessable_entity
    end
  end

  def index
    if params[:loaner_car_id]
      @loaner_car = LoanerCar.find(params[:loaner_car_id])
      @rentals = @loaner_car.rentals
                             .includes(:repair, created_by: {})
                             .order(created_at: :desc)
    else
      @rentals = Rental.includes(:repair, loaner_car: {}, created_by: {})
                       .order(created_at: :desc)
    end
  end

  def show
    @rental = Rental.includes(:loaner_car, :repair)
                    .find(params[:id])
  end

  def edit
    @rental = Rental.find(params[:id])
    @loaner_cars = LoanerCar.all
  end

  def update
    @rental = Rental.find(params[:id])
    if @rental.update(rental_params)
      @rental.loaner_car.update(parking_lot: params[:parking_lot]) if params.key?(:parking_lot)
      redirect_to rental_path(@rental), notice: "貸出情報を更新しました"
    else
      @loaner_cars = LoanerCar.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    rental = Rental.find(params[:id])
    rental.destroy
    redirect_to loaner_cars_path, notice: "貸出を削除しました"
  end

  # 予定より早く返却された場合、終了日（と午前/午後）を今日・今の時間帯に更新する
  def returned
    rental = Rental.find(params[:id])
    destination = params[:tab].present? ? loaner_cars_path(tab: params[:tab]) : rental_path(rental)

    if rental.end_date > Time.zone.today
      period = Time.zone.now.hour < 12 ? "am" : "pm"
      rental.update!(end_date: Time.zone.today, end_period: period)
      redirect_to destination, notice: "返却済みにしました"
    else
      redirect_to destination, alert: "すでに終了日を過ぎています"
    end
  end

  private

  def rental_params
    params.require(:rental).permit(
      :loaner_car_id,
      :repair_id,
      :start_date,
      :end_date,
      :start_period,
      :end_period,
      :customer_name,
      :reason
    )
  end
end
