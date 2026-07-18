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
                             .includes(repair: { car: :customer }, created_by: {})
                             .order(created_at: :desc)
    else
      @rentals = Rental.includes(repair: { car: :customer }, loaner_car: {}, created_by: {})
                       .order(created_at: :desc)
    end
  end

  def show
    @rental = Rental.includes(:loaner_car, repair: { car: :customer })
                    .find(params[:id])
  end

  def edit
    @rental = Rental.find(params[:id])
    @loaner_cars = LoanerCar.all
  end

  def update
    @rental = Rental.find(params[:id])
    if @rental.update(rental_params)
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

  private

  def rental_params
    params.require(:rental).permit(
      :loaner_car_id,
      :repair_id,
      :start_date,
      :end_date,
      :customer_name,
      :reason
    )
  end
end
