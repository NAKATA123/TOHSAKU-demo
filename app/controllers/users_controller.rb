class UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.order(:created_at)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email = "#{@user.employee_number}@tohsaku.local" if @user.email.blank?
    if @user.save
      redirect_to users_path, notice: "ユーザーを追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(edit_params)
      redirect_to users_path, notice: "ユーザー情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    if user == current_user
      redirect_to users_path, alert: "自分自身は削除できません"
    else
      user.destroy
      redirect_to users_path, notice: "ユーザーを削除しました"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :role, :employee_number)
  end

  def edit_params
    params.require(:user).permit(:name, :role, :employee_number)
  end
end
