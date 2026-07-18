class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(employee_number: params[:employee_number])
    if user
      auto_login(user)
      redirect_to root_path
    else
      flash.now[:alert] = "社員番号が正しくありません"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to login_path
  end
end
