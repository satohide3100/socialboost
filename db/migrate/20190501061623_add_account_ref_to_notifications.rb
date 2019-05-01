class AddAccountRefToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_reference :notifications, :account, foreign_key: true
  end
end
