class PushSubscriptionsController < ApplicationController
  before_action :require_login

  def create
    PushSubscription.find_or_create_by(endpoint: params[:endpoint]) do |sub|
      sub.p256dh_key = params[:p256dh_key]
      sub.auth_key   = params[:auth_key]
      sub.user       = current_user
    end
    head :ok
  end

  def destroy
    PushSubscription.find_by(endpoint: params[:endpoint])&.destroy
    head :ok
  end
end
