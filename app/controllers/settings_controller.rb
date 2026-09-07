class SettingsController < ApplicationController
  before_action :require_login

  def index
    @loaner_cars = LoanerCar.order(:created_at)
    @users = User.order(:created_at) if current_user.admin?
  end
end
