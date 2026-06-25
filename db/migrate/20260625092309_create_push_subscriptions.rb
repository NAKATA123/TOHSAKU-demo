class CreatePushSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :push_subscriptions do |t|
      t.text :endpoint
      t.string :p256dh_key
      t.string :auth_key
      t.bigint :user_id

      t.timestamps
    end
  end
end
