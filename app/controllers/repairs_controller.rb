class RepairsController < ApplicationController
  before_action :require_login

  def index
    @status_filter = params[:status].presence
    @counts = {
      all:       Repair.count,
      reception: Repair.reception.count,
      working:   Repair.working.count,
      completed: Repair.completed.count
    }
    @repairs = Repair.order(created_at: :desc)
    @repairs = @repairs.where(status: @status_filter) if @status_filter
    @repairs = @repairs.page(params[:page]).per(15)
  end

  def show
    @repair = Repair.find(params[:id])
  end

  def new
    @repair = Repair.new(received_at: Time.zone.today)
  end

  def create
    @repair = Repair.new(repair_params)

    if @repair.save
      redirect_to repair_path(@repair), notice: "修理を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @repair = Repair.find(params[:id])
  end

  def update
    @repair = Repair.find(params[:id])
    if @repair.update(repair_params)
      redirect_to repair_path(@repair), notice: "修理情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_status
    @repair = Repair.find(params[:id])
    unless Repair.statuses.key?(params[:status])
      return redirect_back_or_to repairs_path, alert: "無効なステータスです"
    end
    attrs = { status: params[:status] }
    attrs[:completed_at] = Time.zone.today if params[:status] == "completed" && @repair.completed_at.nil?
    @repair.update!(attrs)
    redirect_back_or_to repairs_path, notice: "ステータスを更新しました"
  end

  def destroy
    @repair = Repair.find(params[:id])
    @repair.destroy
    redirect_to repairs_path, notice: "修理を削除しました"
  end

  private

  def repair_params
    params.require(:repair).permit(:customer_name, :car_model, :car_number, :description, :status, :received_at, :completed_at)
  end
end
