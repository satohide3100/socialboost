class CreateUnFollowSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :un_follow_settings do |t|
      t.integer :dayLimit
      t.integer :intervalDay
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
