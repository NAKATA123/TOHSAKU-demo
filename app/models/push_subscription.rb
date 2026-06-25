class PushSubscription < ApplicationRecord
  belongs_to :user, optional: true

  def self.broadcast_to_all(title:, body:)
    vapid = {
      subject:     "mailto:#{ENV.fetch('VAPID_SUBJECT', 'admin@example.com')}",
      public_key:  ENV['VAPID_PUBLIC_KEY'],
      private_key: ENV['VAPID_PRIVATE_KEY']
    }
    payload = JSON.generate({ title: title, body: body })

    admin_user_ids = User.where(admin: true).pluck(:id)
    where(user_id: admin_user_ids).find_each do |sub|
      WebPush.payload_send(
        message:  payload,
        endpoint: sub.endpoint,
        p256dh:   sub.p256dh_key,
        auth:     sub.auth_key,
        vapid:    vapid
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      sub.destroy
    rescue => e
      Rails.logger.warn("Push failed: #{e.message}")
    end
  end
end
