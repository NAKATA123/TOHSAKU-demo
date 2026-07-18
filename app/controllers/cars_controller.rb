class CarsController < ApplicationController
  before_action :require_login

  def show
    @car = Car.find(params[:id])
    @repairs = @car.repairs.order(created_at: :desc)
  end

  def new
    @customer = Customer.find(params[:customer_id])
    @car = @customer.cars.build
  end

  def create
    @customer = Customer.find(params[:customer_id])
    @car = @customer.cars.build(car_params)

    if @car.save
      redirect_to customer_path(@customer), notice: "車両を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @car = Car.find(params[:id])
  end

  def update
    @car = Car.find(params[:id])
    if @car.update(car_params)
      redirect_to customer_car_path(@car.customer, @car), notice: "車両情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @car = Car.find(params[:id])
    @car.destroy
    redirect_to customer_path(@car.customer), notice: "車両を削除しました"
  end

  private

  def car_params
    params.require(:car).permit(:car_model, :car_number)
  end
end