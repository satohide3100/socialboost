class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :content
      t.integer :notification_type
      t.integer :isRead
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
