class RemoveAccountFromNotifications < ActiveRecord::Migration[5.2]
  def change
    remove_reference :notifications, :account, foreign_key: true
  end
end
